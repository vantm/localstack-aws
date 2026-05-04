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

output "bucket_arns" {
  value = {
    convert   = module.bucket_convert.bucket_arn
    watermark = module.bucket_watermark.bucket_arn
  }
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}
