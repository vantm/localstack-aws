variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "convert_results_bucket_name" {
  description = "Name of the S3 bucket for conversion results"
  type        = string
}

variable "watermark_results_bucket_name" {
  description = "Name of the S3 bucket for watermark results"
  type        = string
}

variable "dynamodb_access_policy_arn" {
  description = "ARN of the IAM policy for DynamoDB access"
  type        = string
}

variable "s3_access_policy_arn" {
  description = "ARN of the IAM policy for S3 access"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
}

variable "watermark_text" {
  description = "Text to use for watermarking"
  type        = string
  default     = "CONFIDENTIAL"
}

variable "output_format" {
  description = "Output format for converted documents"
  type        = string
  default     = "pdf"
}
