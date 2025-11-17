module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  routes = {
    "POST /slack" = {
      integration = {
        uri                    = module.slack_api.lambda_function_arn
        payload_format_version = "2.0"
      }
    },
    "ANY /conversations" = {
      integration = {
        uri                    = module.conversation_api.lambda_function_arn
        payload_format_version = "2.0"
      }
    },
    "ANY /conversations/{proxy+}" = {
      integration = {
        uri                    = module.conversation_api.lambda_function_arn
        payload_format_version = "2.0"
      }
    }
  }

  name               = var.name
  create_domain_name = false
  protocol_type      = "HTTP"
  tags               = var.tags
}
