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

variable "callback_urls" {
  description = "List of allowed callback URLs for the app client"
  type        = list(string)
  default     = ["https://localhost"]
}

variable "logout_urls" {
  description = "List of allowed logout URLs for the app client"
  type        = list(string)
  default     = ["https://localhost"]
}

variable "domain_prefix" {
  description = "Domain prefix for the Cognito User Pool domain"
  type        = string
  default     = "documents-auth"
}
