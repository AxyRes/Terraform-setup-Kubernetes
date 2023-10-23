locals {
  base_name = "${var.prefix}${var.separator}${var.name}"
}
// Create VPC
resource "aws_vpc" "vpc_k8s" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = local.base_name
  }
}
## Declare AZ in this region. We always assume 3 are available ##
data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnet_k8s" {
  vpc_id     = aws_vpc.vpc_k8s.id 
  cidr_block = var.subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${local.base_name} Network Kubernetes Cluster"
  }
}

resource "aws_internet_gateway" "igw_k8s" {
  vpc_id = aws_vpc.vpc_k8s.id

  tags = {
    Name = "${local.base_name} Internet Gateway Kubernetes Cluster"
  }
}

resource "aws_route_table" "rt_ta_k8s" {
  vpc_id = aws_vpc.vpc_k8s.id
  tags = {
    Name = "${local.base_name} Public Routing Table Kubernetes Cluster"
  }
}

resource "aws_route" "public_subnet_internet_gateway_ipv4" {
  route_table_id         = aws_route_table.rt_ta_k8s.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_k8s.id
}

resource "aws_route_table_association" "rt_association_k8s" {
  subnet_id      = aws_subnet.subnet_k8s.id
  route_table_id = aws_route_table.rt_ta_k8s.id
}

resource "aws_security_group" "vpc_sg_k8s" {
  name        = "VPC-SG-K8S"
  vpc_id      = aws_vpc.vpc_k8s.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = [var.subnet_cidr]
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = [var.subnet_cidr]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
