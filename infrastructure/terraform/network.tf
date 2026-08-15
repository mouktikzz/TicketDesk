data "aws_availability_zones" "available" {
  state = "available"
}

# Reference the live TicketDesk VPC and its subnets (ap-south-1)
# These are data sources to reflect the existing infrastructure without creating new VPC/subnet resources.

data "aws_vpc" "ticketdesk" {
  id = "vpc-0b1b561ab96fac233"
}

data "aws_subnet" "public_az1" {
  id = "subnet-02365ec9f4ac98e0b"
}

data "aws_subnet" "public_az2" {
  id = "subnet-09ec75640e87cc03d"
}

# Note: The original configuration declared additional subnets, route tables and an internet gateway
# for a different VPC (vpc-0ca91f796b08a5ca8). Those resources are not managed here so Terraform does
# not try to create or modify the live environment. If you need Terraform to manage the other VPC,
# reintroduce those resource blocks or import them separately.
