resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = local.project_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = local.project_name
  }
}

# The following networking configuration is for demo purposes ONLY.
# You should ALWAYS implement least privilege access using private subnets, ACLs, and 
# security groups with specific ingress/egress rules, ports, and cidr blocks. 
resource "aws_default_route_table" "main" {
  default_route_table_id = aws_vpc.main.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = local.project_name
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet1_cidr
  availability_zone       = local.az1

  tags = {
    Name = "${local.project_name}-public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.subnet2_cidr
  availability_zone       = local.az2

  tags = {
    Name = "${local.project_name}-public2"
  }
}

resource "aws_default_security_group" "main" {
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.project_name
  }
}