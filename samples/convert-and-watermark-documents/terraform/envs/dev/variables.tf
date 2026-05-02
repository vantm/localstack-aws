variable "aws_region" {
  type = string
}

variable "convert_results_bucket_name" {
  type = string
}

variable "watermark_results_bucket_name" {
  type = string
}

variable "s3_access_policy_name" {
  type = string
}

variable "dynamodb_table_name" {
  type = string
}

variable "dynamodb_access_policy_name" {
  type = string
}

variable "user_pool_name" {
  type = string
}

variable "user_pool_client_name" {
  type = string
}

variable "watermark_text" {
  type = string
}

variable "output_format" {
  type = string
}

variable "api_name" {
  type = string
}

variable "api_description" {
  type = string
}

variable "authorizer_credentials_arn" {
  type = string
}

variable "dashboard_name" {
  type = string
}

variable "retention_in_days" {
  type = number
}

variable "waf_name" {
  type = string
}

variable "waf_description" {
  type = string
}

variable "rate_limit" {
  type = number
}
