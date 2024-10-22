# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = var.all_ip_cidr
    gateway_id = var.igw_id
  }
  tags = {
    Name = "public_rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet1_assoc" {
  subnet_id      = var.public_subnet1_id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet2_assoc" {
  subnet_id      = var.public_subnet2_id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = var.all_ip_cidr
    nat_gateway_id = var.nat_gw_id
  }
  tags = {
    Name = "private_rt"
  }
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_subnet1_assoc" {
  subnet_id      = var.private_subnet1_id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet2_assoc" {
  subnet_id      = var.private_subnet2_id
  route_table_id = aws_route_table.private_rt.id
}