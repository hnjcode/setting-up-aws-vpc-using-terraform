variable "Region_US_West_1_NCalifornia" {
  default = "us-west-1"
}

variable "vpc_cidr_block_map" {
  type = map(string)
  default = {
    "vpc"             = "172.20.0.0/16"
    "public_subnet1"  = "172.20.1.0/24"
    "public_subnet2"  = "172.20.2.0/24"
    "private_subnet1" = "172.20.3.0/24"
    "private_subnet2" = "172.20.4.0/24"
    "all_ip"          = "0.0.0.0/0"
  }
}

variable "Amazon_linux_AMI_US_WEST_1_NCalifornia" {
  default = "ami-09b2477d43bc5d0ac"
}

variable "T2_Micro" {
  default = "t2.micro"
}

variable "Key_Pair_WEB" {
  default = "web-key"
}