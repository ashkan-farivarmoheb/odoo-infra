resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}-${var.project}"
  setting {
    name = "containerInsights"
    value = "disabled"
  }
  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }
}

# Create ECS Capacity Provider
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  count = length(data.external.check_capacity_provider.result) == 0 ? 1 : 0

  name = "${var.environment}-${var.project}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
    }
    managed_termination_protection = "DISABLED"
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_provider" {
 cluster_name = aws_ecs_cluster.ecs_cluster.name
 capacity_providers = [ aws_ecs_capacity_provider.ecs_capacity_provider.name ]

 default_capacity_provider_strategy {
   base              = 0
   weight            = 1
   capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
 }
  depends_on = [ aws_ecs_cluster.ecs_cluster, aws_ecs_capacity_provider.ecs_capacity_provider ]
}
