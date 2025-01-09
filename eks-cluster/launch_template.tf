# Create a launch template for EKS nodes
resource "aws_launch_template" "eks_launch_template" {
  name_prefix   = "eks-${var.environment}-${var.project}"
  image_id      = var.imageId
  instance_type = var.instance_type
  key_name = "${var.ec2_key_name}"

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.eks_worker_sg.id]
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.volume_size
      volume_type = var.volume_type
      encrypted   = true
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  # User data (to bootstrap the node into the EKS cluster)
  user_data = base64encode(templatefile("${path.module}/templates/userdata.tpl", {
    cluster_name       = aws_eks_cluster.eks_cluster.name
    cluster_auth_base64 = aws_eks_cluster.eks_cluster.certificate_authority[0].data
    endpoint           = aws_eks_cluster.eks_cluster.endpoint
    dns_cluster_ip     = cidrhost(aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr, 10)
    ami_id            = var.imageId
    service_ipv4_cidr = aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr
  }))

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-${var.environment}-${var.project}-node"
    }
  }

  depends_on = [
    aws_security_group.eks_worker_sg
  ]
}
