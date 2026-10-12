# 1. VPC Principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-3tier-portfolio"
  }
} 

# 2. Internet Gateway (for public layer)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw-3tier-portfolio"
  }
}

# 3. Subnets Public (ALB, Bastion Host)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# 4. Subnets Private for Application (EC2 instances, ASG)
resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnets_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private-app-subnet-${count.index + 1}"
  }
}

# 5. Subnets Private for Database (RDS instances)
resource "aws_subnet" "private_db" {
  count             = length(var.private_db_subnets_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private-db-subnet-${count.index + 1}"
  }
}

# 6. Group of subnets for the RDS instances (AWS requires)
resource "aws_db_subnet_group" "db" {
  name       = "main-db-subnet-group"
  subnet_ids = aws_subnet.private_db[*].id
  tags = {
    Name = "main-db-subnet-group"
  }
}

# 7. NAT Gateway and Elastic IP (For instance EC2 have access to the Internet. Example: for downloading updates)
resource "aws_eip" "nat" {
    domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "nat-gw-3tier"
  }
  depends_on = [aws_internet_gateway.igw]
}

# 8. Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = {
    Name = "private-route-table"
  }
}

# 9. Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  count          = length(var.private_app_subnets_cidr)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db" {
  count          = length(var.private_db_subnets_cidr)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private.id
}
