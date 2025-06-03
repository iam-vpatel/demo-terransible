locals {
  azs = data.aws_availability_zones.available.names
}

data "aws_availability_zones" "available" {}

resource "random_id" "random" {
  byte_length = 2
}

resource "aws_vpc" "demo_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "demo_vpc-${random_id.random.dec}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "demo_internet_gateway" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "demo_igw-${random_id.random.dec}"
  }
}

resource "aws_route_table" "demo_public_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "demo-public"
  }
}

resource "aws_route" "default_route" {
  route_table_id = aws_route_table.demo_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.demo_internet_gateway.id
}

resource "aws_default_route_table" "demo_private_rt" {
  default_route_table_id = aws_vpc.demo_vpc.default_route_table_id

  tags = {
    Name = "demo_private"
  }
}

resource "aws_subnet" "demo_public_subnet" {
  count = length(var.public_cidrs)
  vpc_id = aws_vpc.demo_vpc.id 
  cidr_block = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = local.azs[count.index]

  tags = {
    Name = "demo-public-${count.index + 1}"
  }
}

resource "aws_subnet" "demo_private_subnet" {
  count = length(var.private_cidrs)
  vpc_id = aws_vpc.demo_vpc.id 
  cidr_block = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone = local.azs[count.index]

  tags = {
    Name = "demo-private-${count.index + 1}"
  }
}