output "api_name" {
  value = aws_api_gateway_rest_api.gateway_api.name
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.gateway_api.execution_arn
}

output "stage_arn" {
  value = aws_api_gateway_stage.main.arn
}

output "stage_url" {
  value = "https://${aws_api_gateway_rest_api.gateway_api.id}.execute-api.us-east-1.amazonaws.com/${aws_api_gateway_stage.main.stage_name}"
}

output "monitoring_dashboard_name" {
  value = aws_cloudwatch_dashboard.main.dashboard_name
}
