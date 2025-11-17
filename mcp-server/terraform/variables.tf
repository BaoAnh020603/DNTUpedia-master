variable "name" {
  type = string
}

variable "db_max_capacity" {
  type    = number
  default = 2
}

variable "db_min_capacity" {
  type = number

  # optimize cost by scaling to 0 ACUs with automatic pause and resume
  # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2-auto-pause.html
  default = 0
}

variable "db_seconds_until_auto_pause" {
  type    = number
  default = 3600
}

variable "db_vpc_id" {
  type = string
}

variable "db_vpc_subnet_ids" {
  type = list(string)
}

variable "mcp_server_lambda_memory_size" {
  type    = number
  default = 256
}

variable "mcp_server_lambda_timeout" {
  type    = number
  default = 60
}

variable "tags" {
  type = map(string)
  default = {
    "Owner" = "katalon-studio/ai-internal-tools"
  }
}
