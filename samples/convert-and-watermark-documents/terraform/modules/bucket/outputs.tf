output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "policy_arn" {
  value = aws_iam_policy.access.arn
}
