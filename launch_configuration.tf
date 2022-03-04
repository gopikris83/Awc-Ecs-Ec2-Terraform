##########################################################
# AWS Launch Configuration
#########################################################

resource "aws_launch_configuration" "tf-launch_configuration" {
  name = "${var.app_name}-launch-config"
  # name_prefix          = "launch-configuration-"
  iam_instance_profile = aws_iam_instance_profile.ecs-instance-profile.name
  image_id             = data.aws_ami.tf-ami.id
  instance_type        = "t2.medium"
  key_name             = "tf-key-pair"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  security_groups             = [aws_security_group.tf-sg-ec2.id]
  associate_public_ip_address = true
  user_data                   = file("user_data.sh")
}

resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCylXmpDYQrl5Hcc+GQAktbQps6bh1C6Ome5KVI/Wx0XutmX+V9vL0D0zT7Lkr/ndVwvLFx2xlFNLmt4aK1p8S6N/PgqpiuattXkqEI8nvUphgNdhV3Ayz8f0ip80cXL7Vsddib9ayl+vOWUzNhW8uScBQxwAPouzCkmdVUaj7DUHEvJrEM0/hVVuJqRsopbJdmQ/0cuiaCeyndibpz9ZE3YMpvwCmWiv/fZi4APWOTjsuPwbzmMajKpxW3S2PGgt5lDx3/69mtXlav3puExqAnUKUeM1xWifjU7SlHnM4OZY2iu+HrrEAu1HiaNL1M+L/lRqnx3kWi+SGavqCInPiMs7R06gwyaXyiRzYO+Cqcg/nMjTANwxcTGAEvWNuQ+YtZgTJ/CAL7zxxLoIQHA2Fot6Y+WSZ72VlhMEMHVa6ya3rDzs3M4cjC75kKQnAE4BigBRkOWs9WxEErdhHN5f3D8yd2x7h5o3oun2pNrWLqv6sS/uOBMD+LNufr0vuZFtc= gkrishna@DESKTOP-94RFTDD"
}

data "aws_ami" "tf-ami" {
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"]
  }

  most_recent = true
  owners      = ["amazon"]
}