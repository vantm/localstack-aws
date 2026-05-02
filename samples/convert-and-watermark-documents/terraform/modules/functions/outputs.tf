output "convert_lambda_invoke_arn" {
  value = aws_lambda_function.convert.invoke_arn
}

output "watermark_lambda_invoke_arn" {
  value = aws_lambda_function.watermark.invoke_arn
}

output "convert_lambda_arn" {
  value = aws_lambda_function.convert.arn
}

output "convert_lambda_name" {
  value = aws_lambda_function.convert.function_name
}

output "watermark_lambda_arn" {
  value = aws_lambda_function.watermark.arn
}

output "watermark_lambda_name" {
  value = aws_lambda_function.watermark.function_name
}

output "convert_ecr_url" {
  value = aws_ecr_repository.convert.repository_url
}

output "watermark_ecr_url" {
  value = aws_ecr_repository.watermark.repository_url
}
