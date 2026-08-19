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
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-api-logs"
    Project     = var.project_name
    Environment = var.environment
  }

  lifecycle {
    ignore_changes = [tags]
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

# ============================================================
# SSM Parameter Store - runtime application configuration
# ============================================================

resource "aws_ssm_parameter" "s3_bucket" {
  name  = "/${var.project_name}/${var.environment}/S3_BUCKET"
  type  = "String"
  value = "ticketdesk-attachments-bucket"

  tags = {
    Name        = "${var.project_name}-S3_BUCKET"
    Project     = var.project_name
    Owner       = "Mouktik"
    Environment = var.environment
    CostCenter  = "TicketDesk"
  }
}

resource "aws_ssm_parameter" "aws_region" {
  name  = "/${var.project_name}/${var.environment}/AWS_REGION"
  type  = "String"
  value = var.aws_region

  tags = {
    Name        = "${var.project_name}-AWS_REGION"
    Project     = var.project_name
    Owner       = "Mouktik"
    Environment = var.environment
    CostCenter  = "TicketDesk"
  }
}

resource "aws_ssm_parameter" "database_name" {
  name  = "/${var.project_name}/${var.environment}/DATABASE_NAME"
  type  = "String"
  value = "ticketdesk"

  tags = {
    Name        = "${var.project_name}-DATABASE_NAME"
    Project     = var.project_name
    Owner       = "Mouktik"
    Environment = var.environment
    CostCenter  = "TicketDesk"
  }
}

resource "aws_ssm_parameter" "database_host" {
  name  = "/${var.project_name}/${var.environment}/DATABASE_HOST"
  type  = "String"
  value = data.aws_db_instance.ticketdesk.address

  tags = {
    Name        = "${var.project_name}-DATABASE_HOST"
    Project     = var.project_name
    Owner       = "Mouktik"
    Environment = var.environment
    CostCenter  = "TicketDesk"
  }
}

resource "aws_ssm_parameter" "database_port" {
  name  = "/${var.project_name}/${var.environment}/DATABASE_PORT"
  type  = "String"
  value = "5432"

  tags = {
    Name        = "${var.project_name}-DATABASE_PORT"
    Project     = var.project_name
    Owner       = "Mouktik"
    Environment = var.environment
    CostCenter  = "TicketDesk"
  }
}

resource "aws_ssm_parameter" "database_user" {
  name  = "/${var.project_name}/${var.environment}/DATABASE_USER"
  type  = "String"
  value = "ticketdeskadmin"

  tags = {
    Name        = "${var.project_name}-DATABASE_USER"
    Project     = var.project_name
    Owner       = "Mouktik"
    Environment = var.environment
    CostCenter  = "TicketDesk"
  }
}

resource "aws_ssm_parameter" "port" {
  name  = "/${var.project_name}/${var.environment}/PORT"
  type  = "String"
  value = tostring(var.container_port)

  tags = {
    Name        = "${var.project_name}-PORT"
    Project     = var.project_name
    Owner       = "Mouktik"
    Environment = var.environment
    CostCenter  = "TicketDesk"
  }
}

resource "aws_iam_role_policy" "read_ssm_parameters" {
  name = "TicketDeskReadSSMParameters"
  role = aws_iam_role.ecs_task_execution.name

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
          aws_ssm_parameter.s3_bucket.arn,
          aws_ssm_parameter.aws_region.arn,
          aws_ssm_parameter.database_name.arn,
          aws_ssm_parameter.database_host.arn,
          aws_ssm_parameter.database_port.arn,
          aws_ssm_parameter.database_user.arn,
          aws_ssm_parameter.port.arn
        ]
      }
    ]
  })
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

# Reference the live database instance used by the application
# It is not managed by Terraform in this repo and must not be duplicated.
data "aws_db_instance" "ticketdesk" {
  db_instance_identifier = "ticketdesk-postgres"
}

resource "aws_sns_topic" "ticketdesk_alerts" {
  name = "ticketdesk-alerts"

  tags = {
    Name        = "ticketdesk-alerts"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "ticketdesk_email" {
  topic_arn = aws_sns_topic.ticketdesk_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
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
      environment = []
      secrets = [
        {
          name      = "PORT"
          valueFrom = aws_ssm_parameter.port.arn
        },
        {
          name      = "AWS_REGION"
          valueFrom = aws_ssm_parameter.aws_region.arn
        },
        {
          name      = "DATABASE_HOST"
          valueFrom = aws_ssm_parameter.database_host.arn
        },
        {
          name      = "DATABASE_PORT"
          valueFrom = aws_ssm_parameter.database_port.arn
        },
        {
          name      = "DATABASE_NAME"
          valueFrom = aws_ssm_parameter.database_name.arn
        },
        {
          name      = "DATABASE_USER"
          valueFrom = aws_ssm_parameter.database_user.arn
        },
        {
          name      = "S3_BUCKET"
          valueFrom = aws_ssm_parameter.s3_bucket.arn
        },
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
    ignore_changes = [tags]
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
    subnets = [
      aws_subnet.public_az1.id,
      aws_subnet.public_az2.id
    ]

    security_groups = [
      aws_security_group.ecs_api.id
    ]

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

resource "aws_cloudwatch_metric_alarm" "ticketdesk_alb_5xx_errors" {
  alarm_name          = "ticketdesk-alb-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.ticketdesk_alerts.arn]

  dimensions = {
    LoadBalancer = data.aws_lb.app.arn_suffix
  }

  tags = {
    Name        = "ticketdesk-alb-5xx-errors"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "ticketdesk_alb_unhealthy_target" {
  alarm_name          = "ticketdesk-alb-unhealthy-target"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Maximum"
  threshold           = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.ticketdesk_alerts.arn]

  dimensions = {
    LoadBalancer = data.aws_lb.app.arn_suffix
    TargetGroup  = data.aws_lb_target_group.api.arn_suffix
  }

  tags = {
    Name        = "ticketdesk-alb-unhealthy-target"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "ticketdesk_rds_cpu_high" {
  alarm_name          = "ticketdesk-rds-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  period              = 300
  statistic           = "Average"
  threshold           = 80
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  alarm_actions       = [aws_sns_topic.ticketdesk_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = data.aws_db_instance.ticketdesk.db_instance_identifier
  }

  tags = {
    Name        = "ticketdesk-rds-cpu-high"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_dashboard" "ticketdesk" {
  dashboard_name = "TicketDesk-Observability"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              data.aws_lb.app.arn_suffix,
              { stat = "Sum", period = 300, region = var.aws_region, visible = true, label = "RequestCount" }
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB RequestCount"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              data.aws_lb.app.arn_suffix,
              { stat = "Sum", period = 300, region = var.aws_region, id = "m1", label = "5xxCount" }
            ],
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              data.aws_lb.app.arn_suffix,
              { stat = "Sum", period = 300, region = var.aws_region, id = "m2", label = "RequestCount" }
            ],
            [
              {
                expression = "100 * m1 / MAX(m2, 1)",
                id         = "e1",
                label      = "5xx Rate (%)",
                period     = 300,
                region     = var.aws_region
              }
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB 5xx Errors / Error Rate"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              data.aws_lb.app.arn_suffix,
              "TargetGroup",
              data.aws_lb_target_group.api.arn_suffix,
              { stat = "Average", period = 300, region = var.aws_region, label = "TargetResponseTime" }
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ALB TargetResponseTime"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ClusterName",
              aws_ecs_cluster.ticketdesk.name,
              "ServiceName",
              aws_ecs_service.api.name,
              { stat = "Average", period = 300, region = var.aws_region, label = "ECS CPU" }
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS CPUUtilization"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/ECS",
              "MemoryUtilization",
              "ClusterName",
              aws_ecs_cluster.ticketdesk.name,
              "ServiceName",
              aws_ecs_service.api.name,
              { stat = "Average", period = 300, region = var.aws_region, label = "ECS Memory" }
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "ECS MemoryUtilization"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            [
              "AWS/RDS",
              "DatabaseConnections",
              "DBInstanceIdentifier",
              data.aws_db_instance.ticketdesk.db_instance_identifier,
              { stat = "Average", period = 300, region = var.aws_region, label = "DB Connections" }
            ]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "RDS DatabaseConnections"
          period  = 300
        }
      }
    ]
  })
}

