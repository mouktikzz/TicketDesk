output "vpc_id" {
  description = "The VPC ID for the TicketDesk environment"
  value       = data.aws_vpc.ticketdesk.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the ALB"
  value       = [data.aws_subnet.public_az1.id, data.aws_subnet.public_az2.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by the ECS tasks (mapped to the live ALB subnets)"
  value       = [data.aws_subnet.public_az1.id, data.aws_subnet.public_az2.id]
}

output "alb_dns_name" {
  description = "DNS name of the TicketDesk application load balancer"
  value       = data.aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the TicketDesk application load balancer"
  value       = data.aws_lb.app.zone_id
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

output "sns_alert_topic_arn" {
  description = "ARN of the TicketDesk SNS alert topic"
  value       = aws_sns_topic.ticketdesk_alerts.arn
}

output "cloudwatch_dashboard_name" {
  description = "Name of the TicketDesk CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.ticketdesk.dashboard_name
}

output "cloudwatch_alarm_names" {
  description = "TicketDesk CloudWatch alarm names"
  value = [
    aws_cloudwatch_metric_alarm.ticketdesk_alb_5xx_errors.alarm_name,
    aws_cloudwatch_metric_alarm.ticketdesk_alb_unhealthy_target.alarm_name,
    aws_cloudwatch_metric_alarm.ticketdesk_rds_cpu_high.alarm_name,
  ]
}
