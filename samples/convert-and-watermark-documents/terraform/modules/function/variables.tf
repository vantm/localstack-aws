variable "name" {
  description = "Base name for all resources (e.g. 'convert' or 'watermark')"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "dynamodb_access_policy_arn" {
  description = "ARN of the DynamoDB access IAM policy"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
}

variable "additional_env_vars" {
  description = "Additional environment variables for the Lambda (e.g. OUTPUT_FORMAT, WATERMARK_TEXT)"
  type        = map(string)
  default     = {}
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "logs_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "s3_buckets" {
  description = "S3 buckets the Lambda can access"
  type = list(object({
    name       = string
    policy_arn = string
  }))
  default = []
}

variable "sqs_event_source_arn" {
  description = "SQS queue ARN to use as Lambda event source trigger (optional)"
  type        = string
  default     = null
}

variable "sqs_event_source_enabled" {
  description = "Enable SQS queue to use as Lambda event source trigger"
  type        = bool
  default     = false
}

variable "sqs_queues" {
  description = "SQS queues the Lambda can access"
  type = list(object({
    name       = string
    url        = string
    policy_arn = string
  }))
  default = []
}
