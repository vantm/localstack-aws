module "root" {
  source = "../../"

  aws_region                    = var.aws_region
  convert_results_bucket_name   = var.convert_results_bucket_name
  watermark_results_bucket_name = var.watermark_results_bucket_name
  s3_access_policy_name         = var.s3_access_policy_name
  dynamodb_table_name           = var.dynamodb_table_name
  dynamodb_access_policy_name   = var.dynamodb_access_policy_name
  user_pool_name                = var.user_pool_name
  user_pool_client_name         = var.user_pool_client_name
  watermark_text                = var.watermark_text
  output_format                 = var.output_format
  api_name                      = var.api_name
  api_description               = var.api_description
  authorizer_credentials_arn    = var.authorizer_credentials_arn
  dashboard_name                = var.dashboard_name
  retention_in_days             = var.retention_in_days
  waf_name                      = var.waf_name
  waf_description               = var.waf_description
  rate_limit                    = var.rate_limit
}
