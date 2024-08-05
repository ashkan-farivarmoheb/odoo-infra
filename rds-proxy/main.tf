locals {
  database_password = var.password != "" && var.password != null ? var.password : join("", random_password.admin_password.*.result)

  username_password = {
    username = var.username
    password = local.database_password
  }

  auth = [
    {
      auth_scheme = "SECRETS"
      description = "Access the database instance using username and password from AWS Secrets Manager"
      iam_auth    = "DISABLED"
      secret_arn  = aws_secretsmanager_secret.rds_username_and_password.arn
    }
  ]

  rds_clusters_map = zipmap(
    range(length(aws_rds_cluster.postgresql.*)),
    aws_rds_cluster.postgresql.*
  )

  security_group_id = data.aws_security_group.odoo_vpc.id
  private_odoo_ids = data.aws_subnets.private-odoo.ids
  name = "${var.environment}-${var.project}"
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = local.name
  subnet_ids = local.private_odoo_ids # Specify your subnet IDs
}

resource "aws_db_instance" "postgresql" {
  identifier              = local.name
  engine                  = "postgres"
  engine_version          = "${var.engine_version}"
  instance_class          = "${var.instance_class}"
  username                = local.username_password.username
  password                = local.username_password.password
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids  = [local.security_group_id]
  allocated_storage       = "${var.allocated_storage}"
  iops                    = "${var.iops}"
  storage_type            = "${var.storage_type}"
  storage_throughput      = "${var.storage_throughput}"
  port                    = 5432
  apply_immediately       = true
  multi_az                = true
  deletion_protection     = false
  skip_final_snapshot     = true
  iam_database_authentication_enabled = false
  network_type = "IPV4"
}