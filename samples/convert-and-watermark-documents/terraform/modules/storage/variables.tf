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
