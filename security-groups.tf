resource "aws_security_group" "tf-sg-alb" {
  name        = "${var.app_name}-alb"
  description = "security-group-alb"
  vpc_id      = aws_vpc.tf-vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = var.app_port
    protocol    = "tcp"
    to_port     = var.app_port
  }

  tags = {
    Name        = "${var.app_name}-sg-alb"
    Environment = var.app_environment
  }

}


resource "aws_security_group" "tf-sg-ec2" {
  name        = "${var.app_name}-sg-ec2"
  description = "security-group-ec2"
  vpc_id      = aws_vpc.tf-vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    from_port       = 0
    protocol        = "tcp"
    security_groups = [aws_security_group.tf-sg-alb.id]
    to_port         = 65535
  }

  tags = {
    Name        = "${var.app_name}-sg-ec2"
    Environment = var.app_environment
  }

}