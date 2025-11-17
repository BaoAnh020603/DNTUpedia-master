variable "name" {
  type = string
}

variable "lambda_memory_size" {
  type    = number
  default = 256
}

variable "lambda_timeout" {
  type    = number
  default = 60
}

variable "knowledge_base_mcp_server_function_url" {
  type = string
}

variable "slack_bot_token" {
  type      = string
  sensitive = true
}

variable "slack_signing_secret" {
  type      = string
  sensitive = true
}

variable "tags" {
  type = map(string)
  default = {
    "Owner" = "katalon-studio/ai-internal-tools"
  }
}
