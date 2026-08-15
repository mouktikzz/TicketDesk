@'
resource "aws_lb" "ticketdesk" {
  name               = "ticketdesk-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb.id
  ]

  subnets = aws_subnet.public[*].id

  tags = {
    Name    = "TicketDesk-ALB"
    Project = var.project_name
  }
}

resource "aws_lb_target_group" "ticketdesk_api" {
  name        = "ticketdesk-api-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.ticketdesk.id

  health_check {
    enabled             = true
    path                = "/api/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "TicketDesk-API-TG"
    Project = var.project_name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ticketdesk.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ticketdesk_api.arn
  }
}
'@ | Set-Content -Encoding utf8 .\alb.tf