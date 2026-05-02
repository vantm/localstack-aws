variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "documents"
}

variable "dynamodb_access_policy_name" {
  description = "Name of the IAM policy for DynamoDB access"
  type        = string
  default     = "lambda-dynamodb-access"
}
