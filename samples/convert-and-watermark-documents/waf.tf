# WAF Web ACL for API Gateway protection
resource "aws_wafv2_web_acl" "api_protection" {
  name        = "api-protection-waf"
  description = "WAF Web ACL for API Gateway protection"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    action {
      block {}
    }

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"
      }
    }

    visibility_config {
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
    }
  }

  rule {
    name     = "RateLimitRule"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
    }
  }

  visibility_config {
    metric_name                = "api-protection-waf"
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
  }
}

# Associate WAF with API Gateway
resource "aws_wafv2_web_acl_association" "api_gateway" {
  resource_arn = aws_api_gateway_stage.main.arn
  web_acl_arn  = aws_wafv2_web_acl.api_protection.arn

  depends_on = [aws_api_gateway_stage.main]
}
