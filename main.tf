terraform {
  required_version = ">=1.0.4"
  backend "s3" {
    bucket = "myapp-s3bucket"
    key    = "myapp/state.tfstate"
    region = "ap-southeast-1"
  }
}

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

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.env_prefix}-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnets_cidr_block[0]]
  public_subnet_tags = {
    Name: "${var.env_prefix}-subnet-1"
  }

  tags = {
    Name: "${var.env_prefix}-vpc"
  }
}

module "myapp-server" {
  source               = "./modules/webserver"
  env_prefix           = var.env_prefix
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.public_subnets[0]
  my_ip                = var.my_ip
  avail_zone           = var.avail_zone
  public_key_location  = var.public_key_location
  # private_key_location = var.private_key_location
  image_name           = var.image_name
  instance_type        = var.instance_type
}