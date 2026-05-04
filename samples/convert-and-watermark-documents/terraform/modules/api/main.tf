resource "aws_api_gateway_rest_api" "gateway_api" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "convert" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  parent_id   = aws_api_gateway_rest_api.gateway_api.root_resource_id
  path_part   = "convert"
}

resource "aws_api_gateway_method" "convert_post" {
  rest_api_id   = aws_api_gateway_rest_api.gateway_api.id
  resource_id   = aws_api_gateway_resource.convert.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "convert_lambda" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  resource_id = aws_api_gateway_resource.convert.id
  http_method = aws_api_gateway_method.convert_post.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.convert_lambda_invoke_arn
}

resource "aws_api_gateway_resource" "watermark" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  parent_id   = aws_api_gateway_rest_api.gateway_api.root_resource_id
  path_part   = "watermark"
}

resource "aws_api_gateway_method" "watermark_post" {
  rest_api_id   = aws_api_gateway_rest_api.gateway_api.id
  resource_id   = aws_api_gateway_resource.watermark.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "watermark_lambda" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  resource_id = aws_api_gateway_resource.watermark.id
  http_method = aws_api_gateway_method.watermark_post.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = var.watermark_lambda_invoke_arn
}

resource "aws_api_gateway_authorizer" "cognito" {
  name          = "cognito-authorizer"
  rest_api_id   = aws_api_gateway_rest_api.gateway_api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [var.user_pool_arn]
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id

  depends_on = [
    aws_api_gateway_method.convert_post,
    aws_api_gateway_method.watermark_post,
    aws_api_gateway_authorizer.cognito,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.gateway_api.id
  stage_name    = "prod"
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = var.logs_retention_in_days
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.monitoring_dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title = "Lambda Invocations"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.convert_lambda_name, { stat = "Sum" }],
            [".", "Invocations", "FunctionName", var.watermark_lambda_name, { stat = "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
        }
      },
      {
        type = "metric"
        properties = {
          title = "Lambda Errors"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", var.convert_lambda_name, { stat = "Sum" }],
            [".", "Errors", "FunctionName", var.watermark_lambda_name, { stat = "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
        }
      },
      {
        type = "metric"
        properties = {
          title = "API Gateway Requests"
          metrics = [
            ["AWS/ApiGateway", "Count", "ApiName", var.api_name, "Stage", "prod", { stat = "Sum" }]
          ]
          period = 300
          stat   = "Sum"
          region = var.region
        }
      },
      {
        type = "metric"
        properties = {
          title = "API Gateway Latency"
          metrics = [
            ["AWS/ApiGateway", "Latency", "ApiName", var.api_name, "Stage", "prod", { stat = "p99" }]
          ]
          period = 300
          stat   = "p99"
          region = var.region
        }
      }
    ]
  })
}
