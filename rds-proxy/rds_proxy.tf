resource "aws_db_proxy" "this" {
  for_each = local.rds_clusters_map

  name                   = "${local.name}-proxy-${each.key}"
  debug_logging          = var.debug_logging
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = var.idle_client_timeout
  require_tls            = var.require_tls
  role_arn               = aws_iam_role.rds_proxy_role.arn
  vpc_security_group_ids = [local.security_group_id]
  vpc_subnet_ids         = local.private_odoo_ids

  dynamic "auth" {
    for_each = local.auth

    content {
      auth_scheme = auth.value.auth_scheme
      description = auth.value.description
      iam_auth    = auth.value.iam_auth
      secret_arn  = auth.value.secret_arn
    }
  }

  tags = {
    Name = local.name
  }

  timeouts {
    create = var.proxy_create_timeout
    update = var.proxy_update_timeout
    delete = var.proxy_delete_timeout
  }
}

resource "aws_db_proxy_default_target_group" "this" {
  for_each = local.rds_clusters_map
  db_proxy_name = aws_db_proxy.this[each.key].name

  dynamic "connection_pool_config" {
    for_each = (
      var.connection_borrow_timeout != null || var.init_query != null || var.max_connections_percent != null ||
      var.max_idle_connections_percent != null || var.session_pinning_filters != null
    ) ? ["true"] : []

    content {
      connection_borrow_timeout    = var.connection_borrow_timeout
      init_query                   = var.init_query
      max_connections_percent      = var.max_connections_percent
      max_idle_connections_percent = var.max_idle_connections_percent
      session_pinning_filters      = var.session_pinning_filters
    }
  }
}

resource "aws_db_proxy_target" "this" {
  for_each = local.rds_clusters_map

  db_cluster_identifier  = each.value.id
  db_proxy_name          = aws_db_proxy.this[each.key].name
  target_group_name      = aws_db_proxy_default_target_group.this[each.key].name
}

resource "aws_secretsmanager_secret" "rds_username_and_password" {
  name                    = "${local.name}-rdssecret"
  description             = "RDS username and password"
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "rds_username_and_password" {
  secret_id     = aws_secretsmanager_secret.rds_username_and_password.id
  secret_string = jsonencode(local.username_password)
}

resource "random_password" "admin_password" {
  count  = var.password == "" || var.password == null ? 1 : 0
  length = 33
  # Leave special characters out to avoid quoting and other issues.
  # Special characters have no additional security compared to increasing length.
  special          = false
  override_special = "!#$%^&*()<>-_"
}