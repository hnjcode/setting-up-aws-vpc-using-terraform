resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = "main_igw"
  }
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}