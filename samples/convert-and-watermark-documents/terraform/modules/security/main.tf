resource "aws_wafv2_web_acl" "api_protection" {
  name        = var.waf_name
  description = var.waf_description
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
        limit              = var.waf_rate_limit
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
    metric_name                = var.waf_name
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
  }
}

resource "aws_wafv2_web_acl_association" "api_gateway" {
  resource_arn = var.api_gateway_stage_arn
  web_acl_arn  = aws_wafv2_web_acl.api_protection.arn
}
