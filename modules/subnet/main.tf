resource "aws_subnet" "public_subnet1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.public_subnet1_cidr
  availability_zone = var.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet1"
  }
}

# Public Subnet 2
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet2"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = var.availability_zone_1
  tags = {
    Name = "private_subnet1"
  }
}

# Private Subnet 2
resource "aws_subnet" "private_subnet2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = var.availability_zone_2
  tags = {
    Name = "private_subnet2"
  }
}

output "public_subnet1_id" {
  value = aws_subnet.public_subnet1.id
}

output "public_subnet2_id" {
  value = aws_subnet.public_subnet2.id
}

output "private_subnet1_id" {
  value = aws_subnet.private_subnet1.id
}

output "private_subnet2_id" {
  value = aws_subnet.private_subnet2.id
}