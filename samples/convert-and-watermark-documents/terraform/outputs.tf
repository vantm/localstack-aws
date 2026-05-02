output "api_url" {
  value = module.api.stage_url
}

output "convert_ecr_url" {
  value = module.function_convert.ecr_url
}

output "watermark_ecr_url" {
  value = module.function_watermark.ecr_url
}

output "user_pool_id" {
  value = module.auth.user_pool_id
}

output "user_pool_client_id" {
  value = module.auth.user_pool_client_id
}
