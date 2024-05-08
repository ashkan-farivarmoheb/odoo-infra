data "aws_vpcs" "odoo" {
  filter {
    name   = "cidr"
    values = ["10.1.0.0/16"]
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

data "aws_subnets" "public-odoo" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.odoo.ids[0]]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = [true]
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