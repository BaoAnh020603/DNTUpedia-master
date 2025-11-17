output "api_endpoint" {
  value = module.api_gateway.api_endpoint
}

output "deep_chat_function_name" {
  value = module.deep_chat.lambda_function_name
}

output "deep_chat_function_url" {
  value = module.deep_chat.lambda_function_url
}


output "slack_api_function_name" {
  value = module.slack_api.lambda_function_name
}

output "slack_sqs_function_name" {
  value = module.slack_sqs.lambda_function_name
}

output "conversation_table_name" {
  description = "Name of the DynamoDB conversation table"
  value       = module.conversation.dynamodb_table_id
}

output "conversation_table_arn" {
  description = "ARN of the DynamoDB conversation table"
  value       = module.conversation.dynamodb_table_arn
}

output "conversation_api_function_name" {
  value = module.conversation_api.lambda_function_name
}

output "conversation_api_endpoint" {
  value = "${module.api_gateway.api_endpoint}/conversations"
}
