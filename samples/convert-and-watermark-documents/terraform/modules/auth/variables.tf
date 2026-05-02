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
