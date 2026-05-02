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

variable "api_gateway_stage_arn" {
  description = "ARN of the API Gateway Stage"
  type        = string
}

variable "waf_rate_limit" {
  description = "Rate limit for RateLimitRule"
  type        = number
  default     = 100
}
