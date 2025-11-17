output "docs_data_source_id" {
  value = awscc_bedrock_data_source.docs.data_source_id
}

output "docs_s3_bucket_id" {
  value = module.docs_bucket.s3_bucket_id
}

output "knowledge_base_id" {
  value = awscc_bedrock_knowledge_base.this.knowledge_base_id
}

output "knowledge_base_mcp_server_function_name" {
  value = module.mcp_server.lambda_function_name
}

output "knowledge_base_mcp_server_function_url" {
  value = module.mcp_server.lambda_function_url
}
