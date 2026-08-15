terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Use a remote S3 backend in production once the state bucket and DynamoDB lock table exist.
  # backend "s3" {
  #   bucket         = "ticketdesk-terraform-state"
  #   key            = "ticketdesk/ecs/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "ticketdesk-terraform-locks"
  #   encrypt        = true
  # }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}
