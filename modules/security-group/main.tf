data "http" "my_ipv4" {
  url = "https://ipv4.icanhazip.com"
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name   = "bastion_sg"
  vpc_id = var.vpc_id

  # Ingress rule to allow SSH from your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ipv4.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_ip_cidr] # Allow all outbound traffic
  }

  tags = {
    Name = "bastion_sg"
  }
}

# Security Group for ELB
resource "aws_security_group" "elb_sg" {
  name        = "elb_sg"
  description = "Allow inbound HTTP traffic to ELB"
  vpc_id      = var.vpc_id

  # Ingress rule for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.all_ip_cidr]
  }

  # Egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_ip_cidr]
  }

  tags = {
    Name = "elb_sg"
  }
}

# Security Group for EC2 in Private Subnet
resource "aws_security_group" "web_sg" {
  name   = "web_sg"
  vpc_id = var.vpc_id

  # Ingress rules
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # Allow SSH access only from Bastion Host private IP
    cidr_blocks = ["${var.bastion_host_pvt_ip}/32"]
  }

  # Allow traffic from ELB security group on port 80 (HTTP)
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb_sg.id] # Allow from ELB SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.all_ip_cidr] # Allow all outbound traffic
  }

  tags = {
    Name = "web_sg"
  }
}


output "bastion_host_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "elb_sg_id" {
  value = aws_security_group.elb_sg.id
}

output "web_sg_id" {
  value = aws_security_group.web_sg.id
}

