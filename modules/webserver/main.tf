# custom security group
resource "aws_security_group" "myapp-sec-grp" {
  name   = "myapp-sec-grp"
  vpc_id = var.vpc_id

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
    values = [var.image_name]
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

  subnet_id                   = var.subnet_id
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