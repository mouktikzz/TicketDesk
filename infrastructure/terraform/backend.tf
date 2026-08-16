terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ticketdesk-terraform-state"
    key            = "ticketdesk/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "ticketdesk-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "ticketdesk"
      Owner       = "Mouktik"
      Environment = "dev"
      CostCenter  = "TicketDesk"
    }
  }
}