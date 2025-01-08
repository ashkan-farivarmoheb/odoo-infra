# Create a launch template for ECS instances
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
      volume_size = "${var.volume_size}" # Adjust based on your needs
      volume_type = "${var.volume_type}"
    }
  }

# User data (to bootstrap the node into the EKS cluster)
  user_data = base64encode(data.template_file.user_data.rendered)

  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }

  depends_on = [
    aws_security_group.eks_worker_sg
  ]
}
