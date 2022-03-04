###########################################################
# AWS Cloudwatch
# Set up CloudWatch group and log stream and retain logs for 30 days
###########################################################
resource "aws_cloudwatch_log_group" "tf_log_group" {
  name              = "/ec2/service/"
  retention_in_days = 30

  tags = {
    Name        = "${var.app_name}-clwg"
    Environment = var.app_environment
  }
}

resource "aws_cloudwatch_log_stream" "ecsfargateapp_log_stream" {
  name           = "ecs"
  log_group_name = aws_cloudwatch_log_group.tf_log_group.name
}