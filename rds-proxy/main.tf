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

resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = local.name
  engine                  = "postgres"
  engine_version          = "${var.engine_version}"
  database_name           = "${var.project}"
  master_username         = local.username_password.username
  master_password         = local.username_password.password
  db_subnet_group_name    = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids  = [local.security_group_id]
  skip_final_snapshot     = true
  iops                    = 3000
  storage_type = "${var.storage_type}"
  
  # Multi-AZ 
  availability_zones       = local.availability_zones

  # Instance configuration
  db_cluster_instance_class = "${var.instance_class}"

  # Database port
  port = 5432

  # Database authentication
  iam_database_authentication_enabled = false

  network_type = "IPV4"

  allocated_storage       = 400  # Set to at least 400 GB to meet IOPS requirements
  apply_immediately = true
  deletion_protection     = false

}