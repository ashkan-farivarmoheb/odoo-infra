resource "random_id" "random_id_prefix" {
  byte_length = 2
}

locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
}

data "aws_vpcs" "odoo" {
  filter {
    name   = "tag:Name"
    values = ["${var.environment}-${var.project}-vpc"]
  }
}

data "aws_subnets" "private-odoo" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.odoo.ids[0]]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = [false]
  }
}

data "aws_security_group" "odoo_vpc" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.odoo.ids[0]]
  }
  filter {
    name = "group-name"
    values = [ "${var.environment}-${var.project}-default-sg" ]
  }
}