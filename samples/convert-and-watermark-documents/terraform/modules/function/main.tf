resource "aws_s3_bucket" "results" {
  bucket = "${var.name}-results"
}

resource "aws_iam_policy" "s3_access" {
  name = "${var.name}-lambda-s3-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.results.arn,
        "${aws_s3_bucket.results.arn}/*"
      ]
    }]
  })
}

resource "aws_ecr_repository" "function" {
  name = "${var.name}-document"
}

resource "aws_ecr_lifecycle_policy" "function" {
  repository = aws_ecr_repository.function.name

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

resource "aws_iam_role" "lambda" {
  name = "${var.name}-lambda-role"

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

resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  role       = aws_iam_role.lambda.name
  policy_arn = var.dynamodb_access_policy_arn
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_lambda_function" "function" {
  function_name = "${var.name}-document"

  image_uri    = "${aws_ecr_repository.function.repository_url}:latest"
  package_type = "Image"

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  role = aws_iam_role.lambda.arn

  environment {
    variables = merge(
      var.additional_env_vars,
      {
        DYNAMO_TABLE = var.dynamodb_table_name
        S3_BUCKET    = aws_s3_bucket.results.id
      }
    )
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_gateway_execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "function" {
  name              = "/aws/lambda/${var.name}-document"
  retention_in_days = var.logs_retention_in_days
}
