output "vpc_id" { value = aws_vpc.ticketdesk.id }
output "public_subnet_ids" { value = aws_subnet.public[*].id }
output "private_subnet_ids" { value = aws_subnet.private[*].id }
output "alb_security_group_id" { value = aws_security_group.alb.id }
output "api_security_group_id" { value = aws_security_group.api.id }
output "database_security_group_id" { value = aws_security_group.database.id }
@'

output "alb_dns_name" {
  value = aws_lb.ticketdesk.dns_name
}

output "alb_url" {
  value = "http://${aws_lb.ticketdesk.dns_name}"
}

output "target_group_arn" {
  value = aws_lb_target_group.ticketdesk_api.arn
}
'@ | Add-Content -Encoding utf8 .\outputs.tf