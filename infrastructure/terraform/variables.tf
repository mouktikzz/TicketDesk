variable "aws_region" {
  description = "AWS region hosting TicketDesk."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project label used in resource tags."
  type        = string
  default     = "TicketDesk"
}

variable "vpc_cidr" {
  description = "CIDR block for the TicketDesk VPC."
  type        = string
  default     = "20.0.0.0/16"
}

variable "availability_zones" {
  description = "The existing Availability Zones, in subnet-number order."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for the public load-balancer subnets."
  type        = list(string)
  default     = ["20.0.1.0/24", "20.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private application and database subnets."
  type        = list(string)
  default     = ["20.0.11.0/24", "20.0.12.0/24"]
}
