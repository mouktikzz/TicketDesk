# These reflect the live ALB -> ECS API -> RDS trust chain. The legacy
# CloudFormation BackendSecurityGroup is intentionally not managed here.
resource "aws_security_group" "alb" {
  name        = "ticketdesk-alb-sg"
  description = "Security group for alb"
  vpc_id      = aws_vpc.ticketdesk.id
}

resource "aws_security_group" "api" {
  name        = "ticketdesk-api-sg"
  description = "Security group for TicketDesk ECS Fargate API"
  vpc_id      = aws_vpc.ticketdesk.id
}

resource "aws_security_group" "database" {
  name        = "ticketdesk-security-RDSecurityGroup-Frt4BM3MfpAZ"
  description = "Security group for TicketDesk PostgreSQL"
  vpc_id      = aws_vpc.ticketdesk.id
  tags        = { Name = "TicketDesk-RDS-SG" }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "api_from_alb" {
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "database_from_api" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.api.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}
