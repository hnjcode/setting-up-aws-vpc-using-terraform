# Bastion Host in Public Subnet 1
resource "aws_instance" "bastion_host" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet1_id
  key_name               = "vpc-bastion-key"
  vpc_security_group_ids = [var.bastion_host_sg_id] # Attach Security Group here
  tags = {
    Name = "bastion_host"
  }
}

# EC2 Instance in Private Subnet
resource "aws_instance" "web_instance1" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.private_subnet1_id
  key_name      = "vpc-web01" # Replace with your existing key name

  # Associate Security Group
  vpc_security_group_ids = [var.web_sg_id]

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
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.private_subnet2_id
  key_name      = "vpc-web01" # Replace with your existing key name

  # Associate Security Group
  vpc_security_group_ids = [var.web_sg_id]

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

output "bastion_host_ip" {
  value = aws_instance.bastion_host.public_ip
}

output "bastion_host_pvt_ip" {
  value = aws_instance.bastion_host.private_ip
}

output "web_instance1_id" {
  value = aws_instance.web_instance1.id
}

output "web_instance2_id" {
  value = aws_instance.web_instance2.id
}