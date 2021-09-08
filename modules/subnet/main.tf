# create subnet
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnets_cidr_block[0]
  availability_zone = var.avail_zone
  tags              = {
    Name: "${var.env_prefix}-subnet-1"
  }
}

# custom internet gateway
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id            = var.vpc_id
  tags              = {
    Name: "${var.env_prefix}-igw"
  }
}

# custom route table
resource "aws_route_table" "myapp-route-table" {
  vpc_id = var.vpc_id
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
#   default_route_table_id = var.default_route_table_id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.myapp-igw.id
#   }
#   tags = {
#     Name: "${var.env_prefix}-default-rtb"
#   }
# }