data "aws_vpc" "odoo" {
  filter {
    name   = "tag:Name"
    values = ["${var.environment}-${var.project}-vpc"]
  }
}

data "aws_subnets" "private-odoo" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.odoo.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = [false]
  }
}

data "aws_subnets" "public-odoo" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.odoo.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = [true]
  }
}

data "aws_security_groups" "vpc-odoo-asg" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.odoo.id]
  }
  filter {
    name = "group-name"
    values = [ "${var.environment}-${var.project}-default-sg" ]
  }
}

data "external" "check_capacity_provider" {
  program = ["bash", "-c", <<EOT
aws ecs describe-capacity-providers \
  --query "capacityProviders[?name=='${var.environment}-${var.project}-ecs-capacity-provider'].name" \
  --output json | jq -r 'if . | length > 0 then {"exists": "true"} else {"exists": "false"} end'
EOT
  ]
}