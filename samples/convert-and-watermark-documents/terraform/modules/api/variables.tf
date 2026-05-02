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

variable "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  type        = string
}

variable "convert_lambda_invoke_arn" {
  description = "Invoke ARN of the convert Lambda function"
  type        = string
}

variable "watermark_lambda_invoke_arn" {
  description = "Invoke ARN of the watermark Lambda function"
  type        = string
}

variable "authorizer_credentials_arn" {
  description = "ARN of the role for API Gateway Authorizer credentials"
  type        = string
  default     = "arn:aws:iam::123456789012:role/APIGatewayAuthorizerRole"
}
