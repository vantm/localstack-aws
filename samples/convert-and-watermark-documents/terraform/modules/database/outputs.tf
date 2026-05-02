output "table_name" {
  value = aws_dynamodb_table.documents.name
}

output "table_arn" {
  value = aws_dynamodb_table.documents.arn
}

output "dynamodb_access_policy_arn" {
  value = aws_iam_policy.dynamodb_access.arn
}
