###########################################################
# AWS VPC
# Create VPC for the aws-ecs-ec2-app deployment
###########################################################
resource "aws_vpc" "tf-vpc" {
  cidr_block           = "172.43.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}

###########################################################
# AWS Internet Gateway
# Create Internet gateway for VPC resources to gain internet access
###########################################################
resource "aws_internet_gateway" "tf-igw" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.app_environment
  }
}
###########################################################
# AWS Nat Gateway
#Nat Gateway for private to public IP translation and routing traffic to internet
###########################################################
resource "aws_nat_gateway" "tf-ngw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.tf_public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.tf-eip.*.id, count.index)
  depends_on    = [aws_internet_gateway.tf-igw]

  tags = {
    Name        = "${var.app_name}-ngw"
    Environment = var.app_environment
  }
}

resource "aws_eip" "tf-eip" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.tf-igw]
}

# Fetch AZ's in the current region
data "aws_availability_zones" "az" {
}

###########################################################
# AWS Public Subnet
# Create Public Subnet, each in differen AZ's
###########################################################
resource "aws_subnet" "tf_public_subnet" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.tf-vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  vpc_id                  = aws_vpc.tf-vpc.id
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet"
    Environment = var.app_environment
  }
}

resource "aws_route_table" "tf-pb-rtb" {
  count  = var.az_count
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-igw.id
  }
}

resource "aws_route" "tf-pb-rt" {
  count                  = var.az_count
  route_table_id         = element(aws_route_table.tf-pb-rtb.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = element(aws_internet_gateway.tf-igw.*.id, count.index)
}

resource "aws_route_table_association" "tf-pb-association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.tf_public_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.tf-pb-rtb.*.id, count.index)
}
###########################################################
# AWS Private Subnet
# Create Private Subnet, each in differen AZ's
###########################################################

resource "aws_subnet" "tf_private_subnet" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.tf-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.az.names[count.index]
  vpc_id            = aws_vpc.tf-vpc.id

  tags = {
    Name        = "${var.app_name}-private-subnet"
    Environment = var.app_environment
  }
}

resource "aws_route_table" "tf-pr-rtb" {
  count  = var.az_count
  vpc_id = aws_vpc.tf-vpc.id
}

resource "aws_route" "tf-pr-rt" {
  count                  = var.az_count
  route_table_id         = element(aws_route_table.tf-pr-rtb.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.tf-ngw.*.id, count.index)
}

resource "aws_route_table_association" "tf-pr-association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.tf_private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.tf-pr-rtb.*.id, count.index)
}
