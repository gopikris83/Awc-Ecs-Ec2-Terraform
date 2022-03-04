##########################################################
# AWS ECS-CLUSTER
#########################################################

resource "aws_ecs_cluster" "tf-ecs" {
  name = "${var.app_name}-ecs-cluster"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.app_name}-ecs-cluster"
    Environment = var.app_environment
  }
}

###########################################################
# AWS ECS-Task Definition
###########################################################
data "aws_ecs_task_definition" "tf-data-tsd" {
  task_definition = aws_ecs_task_definition.tf-ecs-td.family
}

resource "aws_ecs_task_definition" "tf-ecs-td" {
  container_definitions    = data.template_file.task_definiton.rendered
  family                   = "ecsec2app"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
}

resource "aws_ecs_service" "tf-ecs-svc" {
  name                    = var.app_name
  cluster                 = aws_ecs_cluster.tf-ecs.id
  desired_count           = var.app_count
  task_definition         = aws_ecs_task_definition.tf-ecs-td.arn
  launch_type             = "EC2"
  enable_ecs_managed_tags = true
  force_new_deployment    = true

  load_balancer {
    target_group_arn = aws_alb_target_group.tf-tg.arn
    container_name   = var.app_name
    container_port   = 5000
  }

  depends_on = [aws_alb_target_group.tf-tg, aws_alb_listener.tf-alb-listener]

}


data "template_file" "task_definiton" {
  template = file("container_definition.json")
}

# Auto Scaling Target Groups for the ECS CLoudwatch Alarms, triggers based on Memory and Cpu Utilization
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.tf-ecs.name}/${aws_ecs_service.tf-ecs-svc.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = 80
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
  }
}
