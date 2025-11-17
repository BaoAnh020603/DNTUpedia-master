module "slack_api" {
  source = "terraform-aws-modules/lambda/aws"

  # app configuration
  architectures = ["arm64"]
  environment_variables = {
    SLACK_QUEUE_URL = aws_sqs_queue.slack_queue.url

    # TODO: move to secrets manager
    SLACK_SIGNING_SECRET = var.slack_signing_secret
  }
  handler = "slack_api.handler"
  runtime = "nodejs22.x"

  # app package
  create_package          = false
  ignore_source_code_hash = true
  local_existing_package  = "${path.module}/slack_api.zip" # placeholder, will be replaced by `npm run deploy`

  # policies
  allowed_triggers = {
    api_gateway = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.api_execution_arn}/*/*"
    }
  }
  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sqs:SendMessage"]
        Effect   = "Allow"
        Resource = [aws_sqs_queue.slack_queue.arn]
      },
    ]
  })

  # because of the default publish=false
  # https://github.com/terraform-aws-modules/terraform-aws-lambda/issues/36
  create_current_version_allowed_triggers = false

  # others
  function_name = "${var.name}-slack-api"
  memory_size   = var.lambda_memory_size
  tags          = var.tags
  timeout       = 3 # avoid retrying attempts from Slack
}

resource "aws_sqs_queue" "slack_queue" {
  name                       = "${var.name}-slack-queue"
  tags                       = var.tags
  visibility_timeout_seconds = var.lambda_timeout * 6
}

module "slack_sqs" {
  source = "terraform-aws-modules/lambda/aws"

  # app configuration
  architectures = ["arm64"]
  environment_variables = {
    KNOWLEDGE_BASE_MCP_SERVER_FUNCTION_URL = var.knowledge_base_mcp_server_function_url

    # TODO: move to secrets manager
    SLACK_BOT_TOKEN = var.slack_bot_token
  }
  handler = "slack_sqs.handler"
  runtime = "nodejs22.x"

  # app package
  create_package          = false
  ignore_source_code_hash = true
  local_existing_package  = "${path.module}/slack_sqs.zip" # placeholder, will be replaced by `npm run deploy`

  event_source_mapping = {
    sqs = {
      batch_size              = 1
      event_source_arn        = aws_sqs_queue.slack_queue.arn
      function_response_types = ["ReportBatchItemFailures"]
    }
  }

  # policies
  allowed_triggers = {
    sqs = {
      principal  = "sqs.amazonaws.com"
      source_arn = aws_sqs_queue.slack_queue.arn
    }
  }
  attach_policy_json = true
  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["bedrock:InvokeModel*"]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })
  attach_policies    = true
  number_of_policies = 1
  policies           = ["arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"]

  # because of the default publish=false
  # https://github.com/terraform-aws-modules/terraform-aws-lambda/issues/36
  create_current_version_allowed_triggers = false

  # others
  function_name = "${var.name}-slack-sqs"
  memory_size   = var.lambda_memory_size
  tags          = var.tags
  timeout       = var.lambda_timeout
}
