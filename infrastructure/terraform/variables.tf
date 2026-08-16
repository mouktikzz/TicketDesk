variable "aws_region" {
  description = "AWS region where the TicketDesk infrastructure will be deployed"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project tag prefix used across TicketDesk resources"
  type        = string
  default     = "ticketdesk"
}

variable "environment" {
  description = "Deployment environment label"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the TicketDesk VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_az1_cidr" {
  description = "CIDR for the first public subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "public_subnet_az2_cidr" {
  description = "CIDR for the second public subnet"
  type        = string
  default     = "10.20.2.0/24"
}

variable "private_subnet_az1_cidr" {
  description = "CIDR for the first private subnet"
  type        = string
  default     = "10.20.11.0/24"
}

variable "private_subnet_az2_cidr" {
  description = "CIDR for the second private subnet"
  type        = string
  default     = "10.20.12.0/24"
}

variable "ecs_desired_count" {
  description = "Desired number of API tasks in ECS"
  type        = number
  default     = 1
}

variable "ecs_cpu" {
  description = "CPU units for the TicketDesk API container"
  type        = number
  default     = 512
}

variable "ecs_memory" {
  description = "Memory for the TicketDesk API container in MiB"
  type        = number
  default     = 1024
}

variable "container_port" {
  description = "Application port exposed by the FastAPI container"
  type        = number
  default     = 8000
}

variable "ecr_image" {
  description = "Full ECR image URL for the TicketDesk backend, for example ACCOUNT.dkr.ecr.REGION.amazonaws.com/ticketdesk-api:SHA"
  type        = string
  default     = "956118719056.dkr.ecr.ap-south-1.amazonaws.com/ticketdesk-api:1bfa804"
}

variable "task_execution_role_name" {
  description = "Name of the ECS task execution role"
  type        = string
  default     = "ecsTaskExecutionRole"
}

variable "task_role_name" {
  description = "Name of the ECS task role"
  type        = string
  default     = "ticketdesk-api-task-role"
}

variable "notification_email" {
  description = "Email address subscribed to the TicketDesk alert topic"
  type        = string
}
