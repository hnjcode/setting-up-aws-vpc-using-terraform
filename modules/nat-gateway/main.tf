# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = var.nat_eip_id
  subnet_id     = var.public_subnet1_id
  tags = {
    Name = "nat_gateway"
  }
}

output "nat_gw_id" {
  value = aws_nat_gateway.nat_gw.id
}