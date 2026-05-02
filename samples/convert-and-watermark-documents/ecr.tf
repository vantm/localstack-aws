# ECR Repository for convert Lambda
resource "aws_ecr_repository" "convert" {
  name = "convert-document"
}

# ECR Repository for watermark Lambda
resource "aws_ecr_repository" "watermark" {
  name = "watermark-document"
}

# ECR Lifecycle Policy - keep only latest image
resource "aws_ecr_lifecycle_policy" "convert" {
  repository = aws_ecr_repository.convert.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description = "Keep last 5 images"
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = ["v"]
        countType     = "imageCountMoreThan"
        countNumber  = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}