# API Gateway REST API for document conversion and watermarking service
resource "aws_api_gateway_rest_api" "gateway_api" {
  name        = "documents-converter-api"
  description = "API Gateway for document conversion and watermarking service"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# API resource for /convert endpoint
resource "aws_api_gateway_resource" "convert" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  parent_id   = aws_api_gateway_rest_api.gateway_api.root_resource_id
  path_part   = "convert"
}

# POST method for /convert endpoint with Cognito authentication
resource "aws_api_gateway_method" "convert_post" {
  rest_api_id   = aws_api_gateway_rest_api.gateway_api.id
  resource_id   = aws_api_gateway_resource.convert.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

# Lambda integration for /convert endpoint
resource "aws_api_gateway_integration" "convert_lambda" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  resource_id = aws_api_gateway_resource.convert.id
  http_method = aws_api_gateway_method.convert_post.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.convert.invoke_arn
}

# API resource for /watermark endpoint
resource "aws_api_gateway_resource" "watermark" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  parent_id   = aws_api_gateway_rest_api.gateway_api.root_resource_id
  path_part   = "watermark"
}

# POST method for /watermark endpoint with Cognito authentication
resource "aws_api_gateway_method" "watermark_post" {
  rest_api_id   = aws_api_gateway_rest_api.gateway_api.id
  resource_id   = aws_api_gateway_resource.watermark.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

# Lambda integration for /watermark endpoint
resource "aws_api_gateway_integration" "watermark_lambda" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  resource_id = aws_api_gateway_resource.watermark.id
  http_method = aws_api_gateway_method.watermark_post.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.watermark.invoke_arn
}

# Cognito Authorizer for API Gateway
resource "aws_api_gateway_authorizer" "cognito" {
  name                   = "cognito-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.gateway_api.id
  authorizer_credentials = "arn:aws:iam::123456789012:role/APIGatewayAuthorizerRole"
  type                   = "COGNITO_USER_POOLS"
  provider_arns          = [aws_cognito_user_pool.documents_pool.arn]
}

# API Gateway deployment to make the API available
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

# API Gateway stage for deployment
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.gateway_api.id
  stage_name    = "prod"
}
