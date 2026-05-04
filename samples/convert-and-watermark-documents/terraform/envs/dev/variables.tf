variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

variable "aws_region" {
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

variable "monitoring_dashboard_name" {
  type = string
}

variable "logs_retention_in_days" {
  type = number
}

variable "waf_name" {
  type = string
}

variable "waf_description" {
  type = string
}

variable "waf_rate_limit" {
  type = number
}

variable "convert_result_bucket" {
  type = string
}

variable "watermark_result_bucket" {
  type = string
}

variable "queue_name" {
  type = string
}
