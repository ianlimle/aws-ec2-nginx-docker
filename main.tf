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

# create subnet
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnets_cidr_block[0]
  availability_zone = var.avail_zone
  tags              = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

# custom internet gateway
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id            = aws_vpc.myapp-vpc.id
  tags              = {
    Name: "${var.env_prefix}-igw"
  }
}

# custom route table
resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}

# associate custom route table to custom subnet-1
resource "aws_route_table_association" "myapp-rtb-association" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}

# resource "aws_default_route_table" "default-route-table" {
#   default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
#   }
#   tags = {
#     Name: "${var.env_prefix}-default-rtb"
#   }
# }

# custom security group
resource "aws_security_group" "myapp-sec-grp" {
  name   = "myapp-sec-grp"
  vpc_id = aws_vpc.myapp-vpc.id

  # ingress rule for ssh forwarding
  ingress {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port  = 8080
    to_port    = 8080
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name: "${var.env_prefix}-sec-grp"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "ian-dell-latitude"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id                   = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids      = [aws_security_group.myapp-sec-grp.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh-key.key_name

  # run entrypoint script 
  user_data = <<EOF
                  #!/bin/bash
                  sudo yum update -y && sudo yum install -y docker
                  sudo systemctl start docker
                  sudo usermod -aG docker ec2-user
                  docker run -p 8080:8080 nginx
              EOF

  /*
  Provisioners are used as last resort:
  1. breaks idempotency
  2. breaks current-desired state comparison

  Use configuration management tools instead!
  */
  # connection {
  #   type        = "ssh"
  #   host        = self.public_ip
  #   user        = "ec2-user"
  #   private_key = file(var.private_key_location)
  # }

  # provisioner "file" {
  #   source      = "entrypoint-script.sh"
  #   destination = "/home/ec2-user/entrypoint-script.sh"
  # }

  # provisioner "remote-exec" {
  #   # inline = [
  #   #   "sudo yum update -y && sudo yum install -y docker",
  #   #   "sudo systemctl start docker",
  #   #   "sudo usermod -aG docker ec2-user",
  #   #   "docker run -p 8080:8080 nginx",
  #   # ]
  #   script = file("entrypoint-script.sh")
  # }

  # provisioner "local-exec" {
  #   command = "echo ec2 public ip:${self.public_ip}"
  # }

  tags = {
    Name: "${var.env_prefix}-server"
  }
}