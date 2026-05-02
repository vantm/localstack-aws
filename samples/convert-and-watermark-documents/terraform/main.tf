module "storage" {
  source = "./modules/storage"

  convert_results_bucket_name   = var.convert_results_bucket_name
  watermark_results_bucket_name = var.watermark_results_bucket_name
  s3_access_policy_name         = var.s3_access_policy_name
}

module "database" {
  source = "./modules/database"

  table_name                  = var.dynamodb_table_name
  dynamodb_access_policy_name = var.dynamodb_access_policy_name
}

module "auth" {
  source = "./modules/auth"

  user_pool_name       = var.user_pool_name
  user_pool_client_name = var.user_pool_client_name
}

module "functions" {
  source = "./modules/functions"

  dynamodb_table_name           = module.database.table_name # Wait, I didn't output table_name from database module, just ARN. I should add it.
  convert_results_bucket_name   = module.storage.convert_results_bucket_name # Wait, I didn't output bucket_name from storage module.
  watermark_results_bucket_name = module.storage.watermark_results_bucket_name
  dynamodb_access_policy_arn    = module.database.dynamodb_access_policy_arn
  s3_access_policy_arn          = module.storage.s3_access_policy_arn
  api_gateway_execution_arn     = module.api.execution_arn
  watermark_text                = var.watermark_text
  output_format                 = var.output_format
}

module "api" {
  source = "./modules/api"

  api_name                    = var.api_name
  api_description             = var.api_description
  user_pool_arn               = module.auth.user_pool_arn # I didn't output user_pool_arn from auth module.
  convert_lambda_invoke_arn   = module.functions.convert_lambda_invoke_arn # I didn't output invoke_arn.
  watermark_lambda_invoke_arn = module.functions.watermark_lambda_invoke_arn
  authorizer_credentials_arn  = var.authorizer_credentials_arn
}

module "monitoring" {
  source = "./modules/monitoring"

  convert_lambda_name   = module.functions.convert_lambda_name
  watermark_lambda_name = module.functions.watermark_lambda_name
  api_name              = module.api.api_name # I didn't output api_name.
  api_stage             = "prod"
  dashboard_name        = var.dashboard_name
  retention_in_days     = var.retention_in_days
}

module "security" {
  source = "./modules/security"

  waf_name               = var.waf_name
  waf_description        = var.waf_description
  api_gateway_stage_arn  = module.api.stage_arn # I didn't output stage_arn.
  rate_limit             = var.rate_limit
}
