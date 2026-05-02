variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Storage Variables
variable "convert_results_bucket_name" {
  description = "Name of the S3 bucket for conversion results"
  type        = string
  default     = "convert-results"
}

variable "watermark_results_bucket_name" {
  description = "Name of the S3 bucket for watermark results"
  type        = string
  default     = "watermark-results"
}

variable "s3_access_policy_name" {
  description = "Name of the IAM policy for S3 access"
  type        = string
  default     = "lambda-s3-access"
}

# Database Variables
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "documents"
}

variable "dynamodb_access_policy_name" {
  description = "Name of the IAM policy for DynamoDB access"
  type        = string
  default     = "lambda-dynamodb-access"
}

# Auth Variables
variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  default     = "documents-user-pool"
}

variable "user_pool_client_name" {
  description = "Name of the Cognito User Pool Client"
  type        = string
  default     = "documents-api-client"
}

# Functions Variables
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

# API Variables
variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "documents-converter-api"
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "API Gateway for document conversion and watermarking service"
}

variable "authorizer_credentials_arn" {
  description = "ARN of the role for API Gateway Authorizer credentials"
  type        = string
  default     = "arn:aws:iam::123456789012:role/APIGatewayAuthorizerRole"
}

# Monitoring Variables
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

# Security Variables
variable "waf_name" {
  description = "Name of the WAF Web ACL"
  type        = string
  default     = "api-protection-waf"
}

variable "waf_description" {
  description = "Description of the WAF Web ACL"
  type        = string
  default     = "WAF Web ACL for API Gateway protection"
}

variable "rate_limit" {
  description = "Rate limit for RateLimitRule"
  type        = number
  default     = 100
}
