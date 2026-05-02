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
  name                   = "cognito-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.gateway_api.id
  authorizer_credentials = var.authorizer_credentials_arn
  type                   = "COGNITO_USER_POOLS"
  provider_arns          = [var.user_pool_arn]
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
