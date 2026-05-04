output "lambda_invoke_arn" {
  value = aws_lambda_function.function.invoke_arn
}

output "lambda_arn" {
  value = aws_lambda_function.function.arn
}

output "lambda_name" {
  value = aws_lambda_function.function.function_name
}

output "ecr_url" {
  value = aws_ecr_repository.function.repository_url
}

