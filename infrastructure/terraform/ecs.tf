resource "aws_ecs_cluster" "ticketdesk" {
  name = "${var.project_name}-cluster"

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Name        = "${var.project_name}-cluster"
    Project     = var.project_name
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_cloudwatch_log_group" "ticketdesk" {
  name              = "/ecs/${var.project_name}-api"
  retention_in_days = 0

  tags = {
    Name        = "${var.project_name}-api-logs"
    Project     = var.project_name
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [tags, retention_in_days]
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = var.task_execution_role_name

  assume_role_policy = jsonencode({
    Version = "2008-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-ecs-task-exec-role"
    Project     = var.project_name
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name = var.task_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project_name}-ecs-task-role"
    Project     = var.project_name
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Reference the existing Secrets Manager secret for the database password
data "aws_secretsmanager_secret" "db" {
  name = "ticketdesk/db"
}

# Use the latest version of the secret so we can reference its ARN in the task definition
data "aws_secretsmanager_secret_version" "db" {
  secret_id = data.aws_secretsmanager_secret.db.id
}

resource "aws_iam_policy" "task_runtime_config" {
  name = "${var.project_name}-task-runtime-config"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:*:parameter/${var.project_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}


# Inline policy: allow the execution role to read the database secret in Secrets Manager
resource "aws_iam_role_policy" "read_db_exec" {
  name = "TicketDeskReadDatabaseSecret"
  role = aws_iam_role.ecs_task_execution.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadTicketDeskDatabaseSecret",
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "${data.aws_secretsmanager_secret.db.arn}"
    }
  ]
}
POLICY
}

# Inline policy: allow the task role to read the database secret in Secrets Manager
resource "aws_iam_role_policy" "read_db_task" {
  name = "TicketDeskReadDatabaseSecret"
  role = aws_iam_role.ecs_task.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = data.aws_secretsmanager_secret.db.arn
      }
    ]
  })
}

# Inline policy: allow the task role to upload and read from the attachments S3 bucket
resource "aws_iam_role_policy" "upload_to_s3" {
  name = "TicketDeskUploadToS3"
  role = aws_iam_role.ecs_task.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::ticketdesk-attachments-bucket/attachments/*"
        ]
      }
    ]
  })
}

# Reference the existing ALB by name (live resource)
data "aws_lb" "app" {
  name = "ticketdesk-alb"
}

# Reference the existing target group used by the live service
data "aws_lb_target_group" "api" {
  name = "ticketdesk-api-tg"
}

# Reference the existing listener on the ALB (port 80)
data "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.app.arn
  port              = 80
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project_name}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "ticketdesk-api"
      image     = var.ecr_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ticketdesk.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      environment = [
        { name = "PORT", value = tostring(var.container_port) },
        { name = "AWS_REGION", value = var.aws_region },
        { name = "DATABASE_HOST", value = "ticketdesk-postgres.cn648882ywsv.ap-south-1.rds.amazonaws.com" },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = "ticketdesk" },
        { name = "DATABASE_USER", value = "ticketdeskadmin" },
        { name = "S3_BUCKET", value = "ticketdesk-attachments-bucket" }
      ]
      secrets = [
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = "${data.aws_secretsmanager_secret.db.arn}:password::"
        }
      ]
    }
  ])

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  lifecycle {
    ignore_changes = [container_definitions, tags]
  }

  tags = {
    Name        = "${var.project_name}-api-task"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_ecs_service" "api" {
  name                          = "ticketdesk-cluster"
  cluster                       = aws_ecs_cluster.ticketdesk.id
  task_definition               = aws_ecs_task_definition.api.arn
  desired_count                 = var.ecs_desired_count
  launch_type                   = "FARGATE"
  availability_zone_rebalancing = "ENABLED"
  enable_ecs_managed_tags       = true

  network_configuration {
    subnets          = [data.aws_subnet.public_az1.id, data.aws_subnet.public_az2.id]
    security_groups  = [data.aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.api.arn
    container_name   = "ticketdesk-api"
    container_port   = var.container_port
  }

  # No depends_on for the listener: data sources are read during planning

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    ignore_changes = [desired_count, tags, task_definition]
  }

  tags = {
    Name        = "${var.project_name}-service"
    Project     = var.project_name
    Environment = var.environment
  }
}

