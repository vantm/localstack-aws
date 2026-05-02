resource "aws_lambda_function" "convert" {
  function_name = "convert-document"

  image_uri    = "${aws_ecr_repository.convert.repository_url}:latest"
  package_type = "Image"

  memory_size = 512
  timeout     = 30

  role = aws_iam_role.convert_lambda_role.arn

  environment {
    variables = {
      OUTPUT_FORMAT = "pdf"
      DYNAMO_TABLE = aws_dynamodb_table.documents.name
    }
  }
}

resource "aws_iam_role" "convert_lambda_role" {
  name = "convert-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "convert_lambda_logs" {
  role       = aws_iam_role.convert_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "convert_lambda_dynamodb" {
  role       = aws_iam_role.convert_lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

resource "aws_lambda_permission" "api_gateway_convert" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.convert.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway_api.execution_arn}/*/*"
}
