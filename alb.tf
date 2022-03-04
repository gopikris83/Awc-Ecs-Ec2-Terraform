##########################################################
# AWS Load Balancer
# ALB Target Group for registering the targets (EC2 Instance here)
# ALB Listener for routing the traffic to ECS Cluster
#########################################################
resource "aws_alb" "tf-alb" {
  name               = "${var.app_name}-alb"
  security_groups    = [aws_security_group.tf-sg-alb.id]
  load_balancer_type = "application"
  internal           = false
  subnets            = [for subnet in aws_subnet.tf_public_subnet : subnet.id]

  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.app_environment
  }
}

resource "aws_alb_target_group" "tf-tg" {
  name        = var.app_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.tf-vpc.id
  target_type = "instance"

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 3
    protocol            = "HTTP"
    matcher             = "200"
    path                = var.health_check_path
    interval            = 100
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_alb.tf-alb]
}

resource "aws_alb_listener" "tf-alb-listener" {
  load_balancer_arn = aws_alb.tf-alb.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tf-tg.id
  }
}
