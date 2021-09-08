variable subnets_cidr_block {
  description = "cidr blocks for subnet" 
  type        = list(string)
}

variable avail_zone {
  description = "Resource availability zone"
}

variable env_prefix {
  description = "type of environment"
}

variable vpc_id {
  description = "id of VPC"
}

# variable default_route_table_id {
#   description = "id of default aws route table"
# }