resource "aws_efs_file_system" "efs" {
  creation_token = "${var.environment}-${var.project}-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted        = true

  lifecycle_policy {
    transition_to_ia = "AFTER_14_DAYS"
  }

  tags = {
    Name = "${var.environment}-${var.project}-efs"
  }
}

resource "aws_efs_access_point" "odoo_access" {
  file_system_id = aws_efs_file_system.efs.id
  posix_user {
    uid = "10000"
    gid = "10000"
  }
  root_directory {
    creation_info {
      owner_uid = "10000"
      owner_gid = "10000"
      permissions = "0755"
    }
    path = "/mnt/efs"
  }
  tags = {
    Name = "${var.environment}-${var.project}-efs-ap"
    Environment = "${var.environment}"
    Application = "${var.project}"
  }
}

resource "aws_efs_file_system_policy" "odoo_policy" {
  file_system_id = aws_efs_file_system.efs.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Resource": "arn:aws:elasticfilesystem:${var.aws_region}:${var.aws_account_id}:file-system/${aws_efs_file_system.efs.id}",
            "Condition": {
                "StringEquals": {
                    "elasticfilesystem:AccessPointArn": "arn:aws:elasticfilesystem:${var.aws_region}:${var.aws_account_id}:access-point/${aws_efs_access_point.odoo_access.id}",
                    "aws:PrincipalArn": "arn:aws:iam::${var.aws_account_id}:role/odoo-efs-role"
                }
            }
        }
    ]
}
EOF
}

resource "aws_efs_mount_target" "odoo_efs_mount_1" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.aws_subnets.private-odoo.ids[0]
  security_groups = [data.aws_security_group.odoo_vpc.id]
}

resource "aws_efs_mount_target" "odoo_efs_mount_2" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.aws_subnets.private-odoo.ids[1]
  security_groups = [data.aws_security_group.odoo_vpc.id]
}

resource "aws_efs_mount_target" "odoo_efs_mount_3" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = data.aws_subnets.private-odoo.ids[2]
  security_groups = [data.aws_security_group.odoo_vpc.id]
}