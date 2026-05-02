resource "aws_s3_bucket" "convert_results" {
  bucket = "convert-results"
}

resource "aws_s3_bucket" "watermark_results" {
  bucket = "watermark-results"
}

resource "aws_iam_policy" "s3_access" {
  name = "lambda-s3-access"

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
        aws_s3_bucket.convert_results.arn,
        "${aws_s3_bucket.convert_results.arn}/*",
        aws_s3_bucket.watermark_results.arn,
        "${aws_s3_bucket.watermark_results.arn}/*"
      ]
    }]
  })
}
