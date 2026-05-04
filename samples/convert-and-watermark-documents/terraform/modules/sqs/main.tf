resource "aws_sqs_queue" "this" {
  name = var.name
}

resource "aws_iam_policy" "access" {
  name = "${var.name}-sqs-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      Resource = [
        aws_sqs_queue.this.arn
      ]
    }]
  })
}
