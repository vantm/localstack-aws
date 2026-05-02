resource "aws_lambda_function" "watermark" {
  function_name = "watermark-document"

  runtime     = "python3.9"
  handler     = "lambda_function.lambda_handler"
  memory_size = 512
  timeout     = 30

  role         = aws_iam_role.watermark_lambda_role.arn

  filename         = "lambda_watermark.zip"
  source_code_hash = filebase64sha256("lambda_watermark.zip")

  environment {
    variables = {
      WATERMARK_TEXT = "CONFIDENTIAL"
    }
  }
}

resource "aws_iam_role" "watermark_lambda_role" {
  name = "watermark-lambda-role"

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

resource "aws_iam_role_policy_attachment" "watermark_lambda_logs" {
  role       = aws_iam_role.watermark_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_lambda_permission" "api_gateway_watermark" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.watermark.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn   = "${aws_api_gateway_rest_api.gateway_api.execution_arn}/*/*"
}