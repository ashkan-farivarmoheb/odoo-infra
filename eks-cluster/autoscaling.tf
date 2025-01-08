# resource "aws_autoscaling_group" "eks_node_asg" {
#   name                   = "eks-${var.environment}-${var.project}"
#   min_size               = "${var.min_size_asg}"
#   max_size               = "${var.max_size_asg}"
#   desired_capacity       = "${var.desired_size_asg}"
#   vpc_zone_identifier  = data.aws_subnets.private-odoo.ids
#   launch_template {
#     id      = aws_launch_template.eks_launch_template.id
#     version = "$Latest" # Always use the latest version of the launch template
#   }

#   tag {
#     key                 = "Name"
#     value               = "eks-node"
#     propagate_at_launch = true
#   }

#   health_check_type          = "EC2"
#   health_check_grace_period = 300
#   force_delete               = true

#   depends_on = [ aws_launch_template.eks_launch_template, data.aws_subnets.private-odoo ]
# }

# resource "aws_appautoscaling_target" "eks_nodegroup_target" {
#   max_capacity       = var.max_size_asg
#   min_capacity       = var.min_size_asg
#   resource_id        = "cluster/${aws_eks_cluster.eks_cluster.name}/nodegroup/${aws_eks_node_group.eks_node_group.node_group_name}"
#   scalable_dimension = "eks:nodegroup:DesiredCapacity"
#   service_namespace  = "eks"
# }

# resource "aws_appautoscaling_policy" "scale_up" {
#   name                   = "eks-scale-up-policy"
#   policy_type            = "TargetTrackingScaling"
#   resource_id           = aws_appautoscaling_target.eks_nodegroup_target.resource_id
#   scalable_dimension    = aws_appautoscaling_target.eks_nodegroup_target.scalable_dimension
#   service_namespace     = "eks"

#   target_tracking_scaling_policy_configuration {
#     target_value                      = 75.0 # Target CPU utilization
#     predefined_metric_specification {
#       predefined_metric_type = "EC2InstanceAverageCPUUtilization" # Correct metric for EKS nodes
#     }
#     scale_in_cooldown              = 300
#     scale_out_cooldown             = 300
#   }
# }

# resource "aws_appautoscaling_policy" "scale_down" {
#   name                   = "eks-scale-down-policy"
#   policy_type            = "TargetTrackingScaling"
#   resource_id           = aws_appautoscaling_target.eks_nodegroup_target.resource_id
#   scalable_dimension    = aws_appautoscaling_target.eks_nodegroup_target.scalable_dimension
#   service_namespace     = "eks"

#   target_tracking_scaling_policy_configuration {
#     target_value                      = 20.0 # Target CPU utilization
#     predefined_metric_specification {
#       predefined_metric_type = "EC2InstanceAverageCPUUtilization" # Correct metric for EKS nodes
#     }
#     scale_in_cooldown              = 300
#     scale_out_cooldown             = 300
#   }
# }
