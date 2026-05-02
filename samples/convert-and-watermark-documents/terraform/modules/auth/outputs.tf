output "user_pool_arn" {
  value = aws_cognito_user_pool.documents_pool.arn
}

output "user_pool_id" {
  value = aws_cognito_user_pool.documents_pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.documents_client.id
}
