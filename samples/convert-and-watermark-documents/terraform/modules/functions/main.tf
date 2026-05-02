resource "aws_ecr_repository" "convert" {
  name = "convert-document"
}

resource "aws_ecr_lifecycle_policy" "convert" {
  repository = aws_ecr_repository.convert.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = ["v"]
        countType     = "imageCountMoreThan"
        countNumber   = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

resource "aws_ecr_repository" "watermark" {
  name = "watermark-document"
}

resource "aws_ecr_lifecycle_policy" "watermark" {
  repository = aws_ecr_repository.watermark.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = ["v"]
        countType     = "imageCountMoreThan"
        countNumber   = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

resource "aws_lambda_function" "convert" {
  function_name = "convert-document"

  image_uri    = "${aws_ecr_repository.convert.repository_url}:latest"
  package_type = "Image"

  memory_size = 512
  timeout     = 30

  role = aws_iam_role.convert_lambda_role.arn

  environment {
    variables = {
      OUTPUT_FORMAT = var.output_format
      DYNAMO_TABLE  = var.dynamodb_table_name
      S3_BUCKET     = var.convert_results_bucket_name
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
  policy_arn = var.dynamodb_access_policy_arn
}

resource "aws_iam_role_policy_attachment" "convert_lambda_s3" {
  role       = aws_iam_role.convert_lambda_role.name
  policy_arn = var.s3_access_policy_arn
}

resource "aws_lambda_permission" "api_gateway_convert" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.convert.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}

resource "aws_lambda_function" "watermark" {
  function_name = "watermark-document"

  image_uri    = "${aws_ecr_repository.watermark.repository_url}:latest"
  package_type = "Image"

  memory_size = 512
  timeout     = 30

  role = aws_iam_role.watermark_lambda_role.arn

  environment {
    variables = {
      WATERMARK_TEXT = var.watermark_text
      DYNAMO_TABLE   = var.dynamodb_table_name
      S3_BUCKET      = var.watermark_results_bucket_name
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

resource "aws_iam_role_policy_attachment" "watermark_lambda_dynamodb" {
  role       = aws_iam_role.watermark_lambda_role.name
  policy_arn = var.dynamodb_access_policy_arn
}

resource "aws_iam_role_policy_attachment" "watermark_lambda_s3" {
  role       = aws_iam_role.watermark_lambda_role.name
  policy_arn = var.s3_access_policy_arn
}

resource "aws_lambda_permission" "api_gateway_watermark" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.watermark.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}
