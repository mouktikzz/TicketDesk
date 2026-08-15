output "vpc_id" {
  description = "The VPC ID for the TicketDesk environment"
  value       = aws_vpc.ticketdesk.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB"
  value       = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by the ECS tasks"
  value       = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
}

output "alb_dns_name" {
  description = "DNS name of the TicketDesk application load balancer"
  value       = aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the TicketDesk application load balancer"
  value       = aws_lb.app.zone_id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.ticketdesk.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.api.name
}

output "ecr_image" {
  description = "ECR image used by the TicketDesk API task"
  value       = var.ecr_image
}
