resource "aws_iam_role" "rds_proxy_role" {
  name = "rds-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_proxy_policy" {
  role       = aws_iam_role.rds_proxy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess" # Use a correct and available policy ARN
}