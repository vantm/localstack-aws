output "convert_results_bucket_name" {
  value = aws_s3_bucket.convert_results.id
}

output "watermark_results_bucket_name" {
  value = aws_s3_bucket.watermark_results.id
}

output "convert_results_bucket_arn" {
  value = aws_s3_bucket.convert_results.arn
}

output "watermark_results_bucket_arn" {
  value = aws_s3_bucket.watermark_results.arn
}

output "s3_access_policy_arn" {
  value = aws_iam_policy.s3_access.arn
}
