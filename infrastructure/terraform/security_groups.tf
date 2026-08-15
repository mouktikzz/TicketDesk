# Reference the existing ALB and ECS task security groups (they are created outside Terraform)
# ALB security group
data "aws_security_group" "alb" {
  id = "sg-00e87eebde7f90e50"
}

# ECS tasks security group
data "aws_security_group" "ecs_tasks" {
  id = "sg-0534bba921f1dd6fb"
}
