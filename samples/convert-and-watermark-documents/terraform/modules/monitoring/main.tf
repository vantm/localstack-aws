resource "aws_cloudwatch_log_group" "convert_lambda" {
  name              = "/aws/lambda/${var.convert_lambda_name}"
  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_group" "watermark_lambda" {
  name              = "/aws/lambda/${var.watermark_lambda_name}"
  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "Lambda Invocations"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.convert_lambda_name, { stat = "Sum" }],
            [".", "Invocations", "FunctionName", var.watermark_lambda_name, { stat = "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "Lambda Errors"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", var.convert_lambda_name, { stat = "Sum" }],
            [".", "Errors", "FunctionName", var.watermark_lambda_name, { stat = "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "API Gateway Requests"
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_name, "Stage", var.api_stage, { stat = "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = "us-east-1"
        }
      },
      {
        type = "metric"
        properties = {
          title  = "API Gateway Latency"
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiName", var.api_name, "Stage", var.api_stage, { stat = "p99" }]
          ]
          period = 300
          stat   = "p99"
          region = "us-east-1"
        }
      }
    ]
  })
}
