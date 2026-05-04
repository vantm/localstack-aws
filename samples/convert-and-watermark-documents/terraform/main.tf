module "database" {
  source = "./modules/database"

  table_name                  = var.dynamodb_table_name
  dynamodb_access_policy_name = var.dynamodb_access_policy_name
}

module "auth" {
  source = "./modules/auth"

  user_pool_name        = var.user_pool_name
  user_pool_client_name = var.user_pool_client_name
}

module "bucket_convert" {
  source = "./modules/bucket"
  name   = var.convert_result_bucket
}

module "bucket_watermark" {
  source = "./modules/bucket"
  name   = var.watermark_result_bucket
}

module "sqs" {
  source = "./modules/sqs"
  name   = var.queue_name
}

module "function_convert" {
  source = "./modules/function"

  name                       = "convert"
  dynamodb_table_name        = module.database.table_name
  dynamodb_access_policy_arn = module.database.dynamodb_access_policy_arn
  api_gateway_execution_arn  = module.api.execution_arn
  additional_env_vars = {
    OUTPUT_FORMAT = var.output_format
  }
  logs_retention_in_days = var.logs_retention_in_days
  s3_buckets = [{
    name       = module.bucket_convert.bucket_name
    policy_arn = module.bucket_convert.policy_arn
  }]
  sqs_queues = [{
    name       = module.sqs.queue_name
    url        = module.sqs.queue_url
    policy_arn = module.sqs.policy_arn
  }]
}

module "function_watermark" {
  source = "./modules/function"

  name                       = "watermark"
  sqs_event_source_arn       = module.sqs.queue_arn
  dynamodb_table_name        = module.database.table_name
  dynamodb_access_policy_arn = module.database.dynamodb_access_policy_arn
  api_gateway_execution_arn  = module.api.execution_arn
  additional_env_vars = {
    WATERMARK_TEXT = var.watermark_text
  }
  logs_retention_in_days = var.logs_retention_in_days
  s3_buckets = [
    {
      name       = module.bucket_convert.bucket_name
      policy_arn = module.bucket_convert.policy_arn
    },
    {
      name       = module.bucket_watermark.bucket_name
      policy_arn = module.bucket_watermark.policy_arn
    }
  ]
}

module "api" {
  source = "./modules/api"

  api_name                    = var.api_name
  api_description             = var.api_description
  user_pool_arn               = module.auth.user_pool_arn
  convert_lambda_invoke_arn   = module.function_convert.lambda_invoke_arn
  watermark_lambda_invoke_arn = module.function_watermark.lambda_invoke_arn
  convert_lambda_name         = module.function_convert.lambda_name
  watermark_lambda_name       = module.function_watermark.lambda_name
  authorizer_credentials_arn  = var.authorizer_credentials_arn
  logs_retention_in_days      = var.logs_retention_in_days
  monitoring_dashboard_name   = var.monitoring_dashboard_name
}

module "security" {
  source = "./modules/security"

  waf_name              = var.waf_name
  waf_description       = var.waf_description
  api_gateway_stage_arn = module.api.stage_arn
  waf_rate_limit        = var.waf_rate_limit
}
