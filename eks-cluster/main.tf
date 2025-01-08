resource "aws_eks_cluster" "eks_cluster" {
    name = "${var.environment}-${var.project}"
    version  = "1.31"
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
        # endpoint_private_access = true
        # endpoint_public_access  = false
        subnet_ids = data.aws_subnets.private-odoo.ids
        security_group_ids = [aws_security_group.eks_cluster_sg.id]
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
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  
  # Reference the Launch Template
  launch_template {
    id      = aws_launch_template.eks_launch_template.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_policy,
    aws_iam_role_policy_attachment.eks_CNI_policy,
    aws_iam_role_policy_attachment.eks_instance_policy
  ]
}
