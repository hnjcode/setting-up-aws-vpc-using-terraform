provider "aws" {
  region = var.Region_US_West_1_NCalifornia
}

module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block_map.vpc
}

module "igw" {
  source = "./modules/internet-gateway"
  vpc_id = module.vpc.vpc_id
}

module "eip" {
  source = "./modules/elastic-ip"
  igw_id = module.igw.igw_id
}

module "nat_gw" {
  source            = "./modules/nat-gateway"
  nat_eip_id        = module.eip.nat_eip_id
  public_subnet1_id = module.subnet.public_subnet1_id
}

module "rt" {
  source             = "./modules/route-table"
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.igw.igw_id
  nat_gw_id          = module.nat_gw.nat_gw_id
  all_ip_cidr        = var.vpc_cidr_block_map.all_ip
  public_subnet1_id  = module.subnet.public_subnet1_id
  public_subnet2_id  = module.subnet.public_subnet2_id
  private_subnet1_id = module.subnet.private_subnet1_id
  private_subnet2_id = module.subnet.private_subnet2_id
}

module "subnet" {
  source               = "./modules/subnet"
  vpc_id               = module.vpc.vpc_id
  public_subnet1_cidr  = var.vpc_cidr_block_map.public_subnet1
  public_subnet2_cidr  = var.vpc_cidr_block_map.public_subnet2
  private_subnet1_cidr = var.vpc_cidr_block_map.private_subnet1
  private_subnet2_cidr = var.vpc_cidr_block_map.private_subnet2
  availability_zone_1  = var.availability_zone_1
  availability_zone_2  = var.availability_zone_2
}

module "security_group" {
  source              = "./modules/security-group"
  vpc_id              = module.vpc.vpc_id
  bastion_host_pvt_ip = module.ec2.bastion_host_pvt_ip
  all_ip_cidr         = var.vpc_cidr_block_map.all_ip
}

module "ec2" {
  source             = "./modules/ec2"
  public_subnet1_id  = module.subnet.public_subnet1_id
  private_subnet1_id = module.subnet.private_subnet1_id
  private_subnet2_id = module.subnet.private_subnet2_id
  bastion_host_sg_id = module.security_group.bastion_host_sg_id
  web_sg_id          = module.security_group.web_sg_id
  instance_type      = var.T2_Micro
  ami                = var.Amazon_linux_AMI_US_WEST_1_NCalifornia
}

module "elb" {
  source            = "./modules/elb"
  web_instance1_id  = module.ec2.web_instance1_id
  web_instance2_id  = module.ec2.web_instance2_id
  elb_sg_id         = module.security_group.elb_sg_id
  public_subnet1_id = module.subnet.public_subnet1_id
  public_subnet2_id = module.subnet.public_subnet2_id
}
