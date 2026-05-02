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

# POST method for /convert endpoint
resource "aws_api_gateway_method" "convert_post" {
  rest_api_id   = aws_api_gateway_rest_api.gateway_api.id
  resource_id   = aws_api_gateway_resource.convert.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda integration for /convert endpoint
resource "aws_api_gateway_integration" "convert_lambda" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  resource_id = aws_api_gateway_resource.convert.id
  http_method = aws_api_gateway_method.convert_post.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:convert-document/invocations"
}

# API resource for /watermark endpoint
resource "aws_api_gateway_resource" "watermark" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  parent_id   = aws_api_gateway_rest_api.gateway_api.root_resource_id
  path_part   = "watermark"
}

# POST method for /watermark endpoint
resource "aws_api_gateway_method" "watermark_post" {
  rest_api_id   = aws_api_gateway_rest_api.gateway_api.id
  resource_id   = aws_api_gateway_resource.watermark.id
  http_method   = "POST"
  authorization = "NONE"
}

# Lambda integration for /watermark endpoint
resource "aws_api_gateway_integration" "watermark_lambda" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id
  resource_id = aws_api_gateway_resource.watermark.id
  http_method = aws_api_gateway_method.watermark_post.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:123456789012:function:watermark-document/invocations"
}

# API Gateway deployment to make the API available
resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.gateway_api.id

  depends_on = [
    aws_api_gateway_method.convert_post,
    aws_api_gateway_method.watermark_post,
  ]

  lifecycle {
    create_before_destroy = true
  }
}
