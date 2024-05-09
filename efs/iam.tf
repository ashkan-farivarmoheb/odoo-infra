resource "aws_iam_policy" "efs_policy" {
  name        = "${var.environment}-${var.project}-efs-policy"
  description = "IAM policy to ${var.project} ${var.environment} EFS access"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = "arn:aws:elasticfilesystem:${var.aws_region}:${var.aws_account_id}:file-system/${aws_efs_file_system.efs.id}"
        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = "arn:aws:elasticfilesystem:${var.aws_region}:${var.aws_account_id}:access-point/${aws_efs_access_point.odoo_access.id}"
          }
        }
      }
    ]
  })
  depends_on = [aws_efs_file_system.efs, aws_efs_access_point.odoo_access]
}

resource "aws_iam_role" "custom_task_execution_role" {
  name               = "${var.environment}-${var.project}-task-exec-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "ecs_task_execution_role_attachment" {
  name       = "ecs_task_execution_role_attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  roles      = [aws_iam_role.custom_task_execution_role.name]
}

resource "aws_iam_policy_attachment" "custom_efs_policy_attachment" {
  name       = "custom_efs_policy_attachment"
  policy_arn = aws_iam_policy.efs_policy.arn
  roles      = [aws_iam_role.custom_task_execution_role.name]
}
