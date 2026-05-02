resource "aws_s3_bucket" "convert_results" {
  bucket = var.convert_results_bucket_name
}

resource "aws_s3_bucket" "watermark_results" {
  bucket = var.watermark_results_bucket_name
}

resource "aws_iam_policy" "s3_access" {
  name = var.s3_access_policy_name

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
