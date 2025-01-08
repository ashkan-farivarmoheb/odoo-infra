# Create a launch template for EKS nodes
resource "aws_launch_template" "eks_launch_template" {
  name_prefix   = "eks-${var.environment}-${var.project}"
  image_id      = "${var.imageId}"
  instance_type = "${var.instance_type}"
  key_name = "${var.ec2_key_name}"
  vpc_security_group_ids = [aws_security_group.eks_worker_sg.id]

  # Block device mappings, if required
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = "${var.volume_size}"
      volume_type = "${var.volume_type}"
      encrypted   = true
    }
  }

  # User data (to bootstrap the node into the EKS cluster)
  user_data = base64encode(data.template_file.user_data.rendered)

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
    http_put_response_hop_limit = 2
  }

  # Add instance profile
  iam_instance_profile {
    name = aws_iam_instance_profile.eks_node_instance_profile.name
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-${var.environment}-${var.project}-node"
    }
  }

  depends_on = [
    aws_security_group.eks_worker_sg,
    aws_iam_instance_profile.eks_node_instance_profile
  ]
}
