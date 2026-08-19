# ============================================================
# TicketDesk VPC
# ============================================================

resource "aws_vpc" "ticketdesk" {
  cidr_block           = "20.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "TicketDesk-VPC"
    Project     = "ticketdesk"
    Owner       = "Mouktik"
    Environment = "dev"
    CostCenter  = "TicketDesk"
  }
}

# ============================================================
# Internet Gateway
# ============================================================

resource "aws_internet_gateway" "ticketdesk" {
  vpc_id = aws_vpc.ticketdesk.id

  tags = {
    Name        = "TicketDesk-IGW"
    Project     = "ticketdesk"
    Owner       = "Mouktik"
    Environment = "dev"
    CostCenter  = "TicketDesk"
  }
}

# ============================================================
# Public Subnets
# ============================================================

resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.ticketdesk.id
  cidr_block              = "20.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "TicketDesk-Public-Subnet-1"
    Project     = "ticketdesk"
    Owner       = "Mouktik"
    Environment = "dev"
    CostCenter  = "TicketDesk"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.ticketdesk.id
  cidr_block              = "20.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "TicketDesk-Public-Subnet-2"
    Project     = "ticketdesk"
    Owner       = "Mouktik"
    Environment = "dev"
    CostCenter  = "TicketDesk"
  }
}

# ============================================================
# Private Subnets
# ============================================================

resource "aws_subnet" "private_az1" {
  vpc_id                  = aws_vpc.ticketdesk.id
  cidr_block              = "20.0.11.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false

  tags = {
    Name        = "TicketDesk-Private-Subnet-1"
    Project     = "ticketdesk"
    Owner       = "Mouktik"
    Environment = "dev"
    CostCenter  = "TicketDesk"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id                  = aws_vpc.ticketdesk.id
  cidr_block              = "20.0.12.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

  tags = {
    Name        = "TicketDesk-Private-Subnet-2"
    Project     = "ticketdesk"
    Owner       = "Mouktik"
    Environment = "dev"
    CostCenter  = "TicketDesk"
  }
}

# ============================================================
# Public Route Table
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ticketdesk.id

  tags = {
    Name        = "TicketDesk-Public-RouteTable"
    Project     = "ticketdesk"
    Owner       = "Mouktik"
    Environment = "dev"
    CostCenter  = "TicketDesk"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ticketdesk.id
}

resource "aws_route_table_association" "public_az1" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_az1.id
}

resource "aws_route_table_association" "public_az2" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public_az2.id
}

# ============================================================
# Private Route Table
# ============================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ticketdesk.id

  tags = {
    Name = "TicketDesk-Private-RouteTable"
  }
}

resource "aws_route_table_association" "private_az1" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_az1.id
}

resource "aws_route_table_association" "private_az2" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_az2.id
}