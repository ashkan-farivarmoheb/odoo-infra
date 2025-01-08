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
  template = file("${path.module}/templates/userdata.tpl")

  vars = {
    cluster_name       = aws_eks_cluster.eks_cluster.name
    cluster_auth_base64 = aws_eks_cluster.eks_cluster.certificate_authority[0].data
    endpoint           = aws_eks_cluster.eks_cluster.endpoint
    dns_cluster_ip     = cidrhost(aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr, 10)
    ami_id            = var.imageId
  }
}