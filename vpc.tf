provider "aws" {
  region = var.Region_US_West_1_NCalifornia
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr_block_map.vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main_vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "main_igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "nat_eip"
  }
}


# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet1.id
  tags = {
    Name = "nat_gateway"
  }
}

# Public Subnet 1
resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.vpc_cidr_block_map.public_subnet1
  availability_zone = "us-west-1a"
  # for_each = toset(keys({for az, details in data.aws_ec2_instance_type_offerings.my_ins_type:
  #   az => details.instance_types if length(details.instance_types) != 0 }))
  # availability_zone = each.key # You can also use each.value because for list items each.key == each.value
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet1"
  }
}

# Public Subnet 2
resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.vpc_cidr_block_map.public_subnet2
  availability_zone       = "us-west-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet2"
  }
}

# Private Subnet 1
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.vpc_cidr_block_map.private_subnet1
  availability_zone = "us-west-1a"
  tags = {
    Name = "private_subnet1"
  }
}

# Private Subnet 2
resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.vpc_cidr_block_map.private_subnet2
  availability_zone = "us-west-1c"
  tags = {
    Name = "private_subnet2"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = var.vpc_cidr_block_map.all_ip
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet1_assoc" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet2_assoc" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block     = var.vpc_cidr_block_map.all_ip
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private_rt"
  }
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_subnet1_assoc" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet2_assoc" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.private_rt.id
}

# Fetch public IPv4 dynamically
data "http" "my_ipv4" {
  url = "https://ipv4.icanhazip.com"
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name   = "bastion_sg"
  vpc_id = aws_vpc.main_vpc.id

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
    cidr_blocks = [var.vpc_cidr_block_map.all_ip] # Allow all outbound traffic
  }

  tags = {
    Name = "bastion_sg"
  }
}

# Bastion Host in Public Subnet 1
resource "aws_instance" "bastion_host" {
  ami                    = var.Amazon_linux_AMI_US_WEST_1_NCalifornia
  instance_type          = var.T2_Micro
  subnet_id              = aws_subnet.public_subnet1.id
  key_name               = "vpc-bastion-key"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id] # Attach Security Group here
  tags = {
    Name = "bastion_host"
  }
}


# Security Group for EC2 in Private Subnet
resource "aws_security_group" "web_sg" {
  name   = "web_sg"
  vpc_id = aws_vpc.main_vpc.id

  # Ingress rules
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # Allow SSH access only from Bastion Host private IP
    cidr_blocks = ["${aws_instance.bastion_host.private_ip}/32"]
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
    cidr_blocks = [var.vpc_cidr_block_map.all_ip] # Allow all outbound traffic
  }

  tags = {
    Name = "web_sg"
  }
}

# EC2 Instance in Private Subnet
resource "aws_instance" "web_instance1" {
  ami           = var.Amazon_linux_AMI_US_WEST_1_NCalifornia
  instance_type = var.T2_Micro
  subnet_id     = aws_subnet.private_subnet1.id
  key_name      = "vpc-web01" # Replace with your existing key name

  # Associate Security Group
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # User Data (Example: Install Apache on launch)
  user_data = <<-EOF
    #!/bin/bash
    yum install wget unzip httpd -y
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>AZ 1 application up and running</h1>" | sudo tee /var/www/html/index.html
    systemctl restart httpd
  EOF

  tags = {
    Name = "web_instance1"
  }
}

# EC2 Instance in Private Subnet
resource "aws_instance" "web_instance2" {
  ami           = var.Amazon_linux_AMI_US_WEST_1_NCalifornia
  instance_type = var.T2_Micro
  subnet_id     = aws_subnet.private_subnet2.id
  key_name      = "vpc-web01" # Replace with your existing key name

  # Associate Security Group
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # User Data (Example: Install Apache on launch)
  user_data = <<-EOF
    #!/bin/bash
    yum install wget unzip httpd -y
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>AZ 2 application up and running</h1>" | sudo tee /var/www/html/index.html
    systemctl restart httpd
  EOF

  tags = {
    Name = "web_instance2"
  }
}


# Security Group for ELB
resource "aws_security_group" "elb_sg" {
  name        = "elb_sg"
  description = "Allow inbound HTTP traffic to ELB"
  vpc_id      = aws_vpc.main_vpc.id

  # Ingress rule for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block_map.all_ip]
  }

  # Egress rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block_map.all_ip]
  }

  tags = {
    Name = "elb_sg"
  }
}

# Classic ELB in Public Subnets
resource "aws_elb" "classic_elb" {
  name            = "classic-elb"
  subnets         = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  security_groups = [aws_security_group.elb_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  instances = [aws_instance.web_instance1.id, aws_instance.web_instance2.id]

  tags = {
    Name = "classic-elb"
  }
}


