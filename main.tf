provider "aws" {
  region                  = var.region
  shared_credentials_file = var.credentials
  profile                 = var.profile
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags       = {
    Name: "${var.env_prefix}-vpc"
  }
}

module "myapp-subnet" {
  source             = "./modules/subnet"
  subnets_cidr_block = var.subnets_cidr_block
  avail_zone         = var.avail_zone
  env_prefix         = var.env_prefix
  vpc_id             = aws_vpc.myapp-vpc.id
  # default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-server" {
  source               = "./modules/webserver"
  env_prefix           = var.env_prefix
  vpc_id               = aws_vpc.myapp-vpc.id
  subnet_id            = module.myapp-subnet.subnet.id
  my_ip                = var.my_ip
  avail_zone           = var.avail_zone
  public_key_location  = var.public_key_location
  # private_key_location = var.private_key_location
  image_name           = var.image_name
  instance_type        = var.instance_type
}