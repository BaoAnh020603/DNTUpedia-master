module "deep_chat" {
  source = "terraform-aws-modules/lambda/aws"

  # app configuration
  architectures = ["arm64"]
  environment_variables = {
    KNOWLEDGE_BASE_MCP_SERVER_FUNCTION_URL = var.knowledge_base_mcp_server_function_url
  }
  handler = "deep_chat.handler"
  runtime = "nodejs22.x"

  # app package
  create_package          = false
  ignore_source_code_hash = true
  local_existing_package  = "${path.module}/deep_chat.zip" # placeholder, will be replaced by `npm run deploy`

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
        Action   = ["bedrock:InvokeModel*"]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })

  # because of the default publish=false
  # https://github.com/terraform-aws-modules/terraform-aws-lambda/issues/36
  create_current_version_allowed_triggers = false

  # others
  function_name = "${var.name}-deep-chat"
  memory_size   = var.lambda_memory_size
  tags          = var.tags
  timeout       = var.lambda_timeout
}
