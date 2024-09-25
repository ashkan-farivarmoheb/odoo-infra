resource "aws_service_discovery_private_dns_namespace" "service_discovery_dns" {
  name        = "${var.environment}-${var.project}.local"
  description = "${var.environment}-${var.project} private dns namespace"
  vpc         = data.aws_vpc.odoo.id
}

resource "aws_service_discovery_service" "service_discovery" {
  name = "${var.environment}-${var.project}-discovery"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.service_discovery_dns.id

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