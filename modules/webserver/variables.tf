variable env_prefix {
  description = "type of environment"
}

variable avail_zone {
  description = "Resource availability zone"
}

variable vpc_id {
  description = "id of VPC"
}

variable subnet_id {
  description = "id of subnet"
}

variable my_ip {
  description = "ip address used in ingress cidr block for ssh"
}

variable public_key_location {
  description = "path to my public id_rsa.pub key" 
}

# variable private_key_location {
#   description = "path to my private id_rsa key" 
# }

variable image_name {
  description = "AMI image name"
}

variable instance_type {
  description = "type of instance"
}