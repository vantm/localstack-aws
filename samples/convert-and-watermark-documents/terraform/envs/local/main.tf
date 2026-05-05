module "root" {
  source = "../../"

  environment                 = var.environment
  project_name                = var.project_name
  aws_region                  = var.aws_region
  dynamodb_table_name         = var.dynamodb_table_name
  dynamodb_access_policy_name = var.dynamodb_access_policy_name
  user_pool_name              = var.user_pool_name
  user_pool_client_name       = var.user_pool_client_name
  domain_prefix               = var.domain_prefix
  callback_urls               = var.callback_urls
  logout_urls                 = var.logout_urls
  watermark_text              = var.watermark_text
  output_format               = var.output_format
  api_name                    = var.api_name
  api_description             = var.api_description
  monitoring_dashboard_name   = var.monitoring_dashboard_name
  logs_retention_in_days      = var.logs_retention_in_days
  waf_name                    = var.waf_name
  waf_description             = var.waf_description
  waf_rate_limit              = var.waf_rate_limit
  convert_result_bucket       = var.convert_result_bucket
  watermark_result_bucket     = var.watermark_result_bucket
  queue_name                  = var.queue_name
}
