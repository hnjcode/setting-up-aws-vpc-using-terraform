# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  depends_on = [var.igw_id]
  tags = {
    Name = "nat_eip"
  }
}

output "nat_eip_id" {
  value = aws_eip.nat_eip.id
}