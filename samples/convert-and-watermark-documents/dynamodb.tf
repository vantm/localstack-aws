resource "aws_dynamodb_table" "documents" {
  name         = "documents"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  range_key    = "created_at"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }
}

resource "aws_iam_policy" "dynamodb_access" {
  name = "lambda-dynamodb-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:DescribeTable"
      ]
      Resource = [
        aws_dynamodb_table.documents.arn,
        "${aws_dynamodb_table.documents.arn}/index/*"
      ]
    }]
  })
}
