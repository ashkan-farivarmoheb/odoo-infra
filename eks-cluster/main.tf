resource "aws_eks_cluster" "eks_cluster" {
    name = "${var.environment}-${var.project}"
    version  = "1.31"
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
        subnet_ids = data.aws_subnets.private-odoo.ids
        security_group_ids = [aws_security_group.eks_cluster_sg.id]
        endpoint_private_access = true
        endpoint_public_access  = true
    }

    kubernetes_network_config {
        service_ipv4_cidr = "172.20.0.0/16"
    }

    tags = {
        Environment = "${var.environment}"
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks_cluster_policy,
        aws_iam_role_policy_attachment.eks_vpc_resource_controller_policy
    ]
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.environment}-${var.project}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = data.aws_subnets.private-odoo.ids

  scaling_config {
    desired_size = var.desired_size_asg
    max_size     = var.max_size_asg
    min_size     = var.min_size_asg
  }
  
  launch_template {
    id      = aws_launch_template.eks_launch_template.id
    version = aws_launch_template.eks_launch_template.latest_version
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_policy,
    aws_iam_role_policy_attachment.eks_CNI_policy,
    aws_iam_role_policy_attachment.eks_instance_policy,
    aws_launch_template.eks_launch_template
  ]

  tags = {
    "Name" = "${var.environment}-${var.project}-node"
  }
}
