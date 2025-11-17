module "mcp_server" {
  source = "terraform-aws-modules/lambda/aws"

  # app configuration
  architectures = ["arm64"]
  environment_variables = {
    DOCS_S3_BUCKET_ID = module.docs_bucket.s3_bucket_id
    KNOWLEDGE_BASE_ID = awscc_bedrock_knowledge_base.this.knowledge_base_id
  }
  handler = "mcp_server.handler"
  runtime = "nodejs22.x"

  # app package
  create_package          = false
  ignore_source_code_hash = true
  local_existing_package  = "${path.module}/mcp_server.zip" # placeholder, will be replaced by `npm run deploy`

  # lambda function URL
  create_lambda_function_url = true
  authorization_type         = "NONE"
  invoke_mode                = "RESPONSE_STREAM"

  # policies
  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["bedrock:Retrieve"]
        Effect   = "Allow"
        Resource = [awscc_bedrock_knowledge_base.this.knowledge_base_arn]
      },
    ]
  })

  # because of the default publish=false
  # https://github.com/terraform-aws-modules/terraform-aws-lambda/issues/36
  create_current_version_allowed_triggers = false

  # others
  function_name = "${var.name}-mcp-server"
  memory_size   = var.mcp_server_lambda_memory_size
  tags          = var.tags
  timeout       = var.mcp_server_lambda_timeout
}
