variable credentials {
  description = "credentials file for AWS"
}

variable profile {
  description = "profile for credentials ie. default"
}

variable public_key_location {
  description = "path to my public id_rsa.pub key" 
}

variable private_key_location {
  description = "path to my private id_rsa key" 
}

variable region {
  description = "Resource region in AWS"
  default     = "ap-southeast-1"
}

variable avail_zone {
  description = "Resource availability zone"
  default     = "ap-southeast-1b"
}

variable alt_avail_zone {
  description = "Alternative resource availability zone"
  default     = "ap-southeast-1c"
}

variable env_prefix {
  description = "type of environment"
  default     = "dev"
}

variable vpc_cidr_block {
  description = "cidr block for vpc" 
  type        = string
}

variable subnets_cidr_block {
  description = "cidr blocks for subnet" 
  type        = list(string)
}

variable my_ip {
  description = "ip address used in ingress cidr block for ssh"
}

variable instance_type {
  description = "type of instance"
  default     = "t2.micro"
}