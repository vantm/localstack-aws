resource "aws_cloudwatch_log_group" "convert_lambda" {
  name              = "/aws/lambda/convert-document"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "watermark_lambda" {
  name              = "/aws/lambda/watermark-document"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/documents-converter-api"
  retention_in_days = 7
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "documents-api-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "Lambda Invocations"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "convert-document", { stat = "Sum" }],
            [".", "Invocations", "FunctionName", "watermark-document", { stat = "Sum" }]
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
            ["AWS/Lambda", "Errors", "FunctionName", "convert-document", { stat = "Sum" }],
            [".", "Errors", "FunctionName", "watermark-document", { stat = "Sum" }]
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
            ["AWS/ApiGateway", "Count", "ApiName", "documents-converter-api", "Stage", "prod", { stat = "Sum" }]
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
            ["AWS/ApiGateway", "Latency", "ApiName", "documents-converter-api", "Stage", "prod", { stat = "p99" }]
          ]
          period = 300
          stat   = "p99"
          region = "us-east-1"
        }
      }
    ]
  })
}