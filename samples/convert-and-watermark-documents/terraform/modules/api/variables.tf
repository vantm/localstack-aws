variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "documents-converter-api"
}

variable "region" {
  description = "Region to put metrics"
  type        = string
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "API Gateway for document conversion and watermarking service"
}

variable "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  type        = string
}

variable "convert_lambda_invoke_arn" {
  description = "Invoke ARN of the convert Lambda function"
  type        = string
}

variable "convert_lambda_name" {
  description = "Name of the convert Lambda function"
  type        = string
}

variable "logs_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "monitoring_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
  default     = "documents-api-monitoring"
}
