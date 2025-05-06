resource "aws_ecs_cluster" "mcp_server" {
  name = local.project_name
}

resource "aws_ecs_cluster_capacity_providers" "mcp_server" {
  cluster_name       = aws_ecs_cluster.mcp_server.name
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_cloudwatch_log_group" "mcp_server" {
  name              = "/ecs/${local.project_name}"
  retention_in_days = 7
}


resource "aws_iam_role" "ecs_task_role" {
  name = local.project_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "mcp_server" {
  family                   = local.project_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  cpu                      = 512
  memory                   = 1024

  container_definitions = jsonencode([
    {
      name      = local.ecs_task_container_name
      image     = local.ecs_task_container_image
      essential = true

      portMappings = [{
        containerPort = local.ecs_task_container_port
        hostPort      = local.ecs_task_container_port
        protocol      = "tcp"
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.mcp_server.name
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "mcp_server" {
  name                 = local.project_name
  cluster              = aws_ecs_cluster.mcp_server.id
  task_definition      = aws_ecs_task_definition.mcp_server.arn

  desired_count        = 3
  force_new_deployment = true
  launch_type          = "FARGATE"
  platform_version     = "LATEST"

  network_configuration {
    subnets          = [aws_subnet.public1.id, aws_subnet.public2.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mcp_server.arn
    container_name   = local.ecs_task_container_name
    container_port   = local.ecs_task_container_port
  }

  triggers = {
    redeploy = plantimestamp()
  }

  # depends_on = [ aws_acm_certificate_validation.cert_validation ]
}

