resource "aws_service_discovery_private_dns_namespace" "service_discovery" {
  name        = "${var.environment}-${var.project}"
  description = "${var.environment}-${var.project} private dns namespace"
  vpc         = data.aws_vpcs.odoo.id
}

resource "aws_service_discovery_service" "example" {
  name = "odoo-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.service_discovery.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}