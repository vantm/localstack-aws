variable "convert_lambda_name" {
  description = "Name of the convert Lambda function"
  type        = string
}

variable "watermark_lambda_name" {
  description = "Name of the watermark Lambda function"
  type        = string
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "api_stage" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}

variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
  default     = "documents-api-monitoring"
}

variable "retention_in_days" {
  description = "Retention period for log groups in days"
  type        = number
  default     = 7
}
