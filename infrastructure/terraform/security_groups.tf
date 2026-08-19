# ============================================================
# ALB Security Group
# ============================================================

resource "aws_security_group" "alb" {
  name        = "ticketdesk-alb-sg"
  description = "Security group for alb"
  vpc_id      = aws_vpc.ticketdesk.id

  tags = {
    Name        = "ticketdesk-alb-sg"
    Project     = "ticketdesk"
    Owner       = "Mouktik"
    Environment = "dev"
    CostCenter  = "TicketDesk"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "-1"
}


# ============================================================
# ECS/API Security Group
# ============================================================

resource "aws_security_group" "ecs_api" {
  name        = "ticketdesk-api-sg"
  description = "Security group for TicketDesk ECS Fargate API"
  vpc_id      = aws_vpc.ticketdesk.id

  tags = {
    Name        = "ticketdesk-api-sg"
    Project     = "ticketdesk"
    Owner       = "Mouktik"
    Environment = "dev"
    CostCenter  = "TicketDesk"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id            = aws_security_group.ecs_api.id
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = 8000
  to_port     = 8000
  ip_protocol = "tcp"

  description = "Allow API traffic from ALB"
}

resource "aws_vpc_security_group_egress_rule" "ecs_all" {
  security_group_id = aws_security_group.ecs_api.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "-1"
}


# ============================================================
# RDS Security Group
# ============================================================

resource "aws_security_group" "rds" {
  name        = "ticketdesk-security-RDSecurityGroup-Frt4BM3MfpAZ"
  description = "Security group for TicketDesk PostgreSQL"
  vpc_id      = aws_vpc.ticketdesk.id

  tags = {
    Name        = "ticketdesk-security-RDSecurityGroup-Frt4BM3MfpAZ"
    Project     = "ticketdesk"
    Owner       = "Mouktik"
    Environment = "dev"
    CostCenter  = "TicketDesk"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.ecs_api.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "PostgreSQL access only from TicketDesk ECS"
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_legacy_backend" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = "sg-01edcba4cf55f7223"

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"

  description = "Existing legacy backend access"
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "-1"
}