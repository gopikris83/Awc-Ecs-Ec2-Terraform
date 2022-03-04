##########################################################
# AWS AutoScaling Group
#########################################################
resource "aws_autoscaling_group" "tf-asg" {
  name                      = var.app_name
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  force_delete              = true
  launch_configuration      = aws_launch_configuration.tf-launch_configuration.name
  max_size                  = 3
  min_size                  = 1

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "${var.app_name}-asg"
  }

  tag {
    key                 = "Environment"
    propagate_at_launch = true
    value               = "Test"
  }

  metrics_granularity  = "1Minute"
  target_group_arns    = [aws_alb_target_group.tf-tg.arn]
  termination_policies = ["OldestInstance"]
  #availability_zones   = ["eu-central-1a", "eu-central-1b"]

  vpc_zone_identifier = [for subnet in aws_subnet.tf_public_subnet : subnet.id]
}

resource "aws_autoscaling_policy" "tf-asg-policy" {
  name                   = "${var.app_name}-scaling-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.tf-asg.name
}
