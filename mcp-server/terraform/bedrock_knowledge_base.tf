data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

module "docs_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  acl                      = "private"
  bucket                   = "${var.name}-docs-bucket"
  block_public_acls        = true
  block_public_policy      = true
  control_object_ownership = true
  force_destroy            = true
  object_ownership         = "BucketOwnerPreferred"
  tags                     = var.tags
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "16.8"
}

module "postgresql" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = "${var.name}-db"
  engine         = data.aws_rds_engine_version.postgresql.engine
  engine_version = data.aws_rds_engine_version.postgresql.version

  # resources: serverless v2
  engine_mode    = "provisioned"
  instance_class = "db.serverless"
  instances      = { one = {} }
  serverlessv2_scaling_configuration = {
    min_capacity             = var.db_min_capacity
    max_capacity             = var.db_max_capacity
    seconds_until_auto_pause = var.db_seconds_until_auto_pause
  }

  # networking: use the default VPC to minimize cost
  create_db_subnet_group = true
  subnets                = var.db_vpc_subnet_ids
  vpc_id                 = var.db_vpc_id

  # others
  apply_immediately    = true
  database_name        = "postgres"
  enable_http_endpoint = true
  master_username      = "root"
  skip_final_snapshot  = true
  tags                 = var.tags
}

resource "terraform_data" "db_setup" {
  depends_on = [module.postgresql]

  # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.VectorDB.html
  provisioner "local-exec" {
    command = <<-EOF

set -e

function execute_sql() {
  aws rds-data execute-statement \
    --resource-arn "$DB_ARN" \
    --database "$DB_NAME" \
    --secret-arn "$SECRET_ARN" \
    --sql "$1"
}

execute_sql "CREATE EXTENSION IF NOT EXISTS vector;"
execute_sql "CREATE SCHEMA bedrock_integration;"
execute_sql "CREATE TABLE bedrock_integration.bedrock_kb (id uuid PRIMARY KEY, embedding vector(1024), chunks text, metadata json, custom_metadata jsonb);"
execute_sql "CREATE INDEX ON bedrock_integration.bedrock_kb USING hnsw (embedding vector_cosine_ops) WITH (ef_construction=256);"
execute_sql "CREATE INDEX ON bedrock_integration.bedrock_kb USING gin (to_tsvector('simple', chunks));"
execute_sql "CREATE INDEX ON bedrock_integration.bedrock_kb USING gin (custom_metadata);"
EOF

    environment = {
      DB_ARN     = module.postgresql.cluster_arn
      DB_NAME    = module.postgresql.cluster_database_name
      SECRET_ARN = module.postgresql.cluster_master_user_secret[0].secret_arn
    }

    interpreter = ["bash", "-c"]
  }
}

resource "aws_iam_role" "this" {
  name = "${var.name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "this" {
  name = "${var.name}-policy"
  role = aws_iam_role.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["bedrock:GetFoundationModel", "bedrock:InvokeModel*"]
        Resource = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v2:0"
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = module.postgresql.cluster_master_user_secret[0].secret_arn
      },
      {
        Effect   = "Allow"
        Action   = ["rds:DescribeDBClusters", "rds-data:ExecuteStatement", "rds-data:BatchExecuteStatement"]
        Resource = module.postgresql.cluster_arn
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetBucket*", "s3:GetObject*", "s3:List*"]
        Resource = [module.docs_bucket.s3_bucket_arn, "${module.docs_bucket.s3_bucket_arn}/*"]
      }
    ]
  })
}

resource "awscc_bedrock_knowledge_base" "this" {
  name       = var.name
  depends_on = [terraform_data.db_setup]
  role_arn   = aws_iam_role.this.arn

  knowledge_base_configuration = {
    type = "VECTOR"
    vector_knowledge_base_configuration = {
      embedding_model_arn = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/amazon.titan-embed-text-v2:0"
      embedding_model_configuration = {
        bedrock_embedding_model_configuration = {
          dimensions          = 1024
          embedding_data_type = "FLOAT32"
        }
      }
    }
  }

  storage_configuration = {
    type = "RDS"
    rds_configuration = {
      credentials_secret_arn = module.postgresql.cluster_master_user_secret[0].secret_arn
      database_name          = module.postgresql.cluster_database_name
      field_mapping = {
        metadata_field        = "metadata"
        primary_key_field     = "id"
        text_field            = "chunks"
        vector_field          = "embedding"
        custom_metadata_field = "custom_metadata"
      }
      resource_arn = module.postgresql.cluster_arn
      table_name   = "bedrock_integration.bedrock_kb"
    }
  }
}

resource "awscc_bedrock_data_source" "docs" {
  name              = "${var.name}-docs-data-source"
  knowledge_base_id = awscc_bedrock_knowledge_base.this.knowledge_base_id
  data_source_configuration = {
    type             = "S3"
    s3_configuration = { bucket_arn = module.docs_bucket.s3_bucket_arn }
  }
}
