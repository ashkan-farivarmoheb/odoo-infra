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

data "template_file" "user_data" {
  template = <<-EOT
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${aws_eks_cluster.eks_cluster.name} \
      --apiserver-endpoint ${aws_eks_cluster.eks_cluster.endpoint} \
      --b64-cluster-ca ${aws_eks_cluster.eks_cluster.certificate_authority[0].data}
  EOT
}