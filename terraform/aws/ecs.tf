resource "aws_ecs_cluster" "main" {
  name = "ads-platform-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "ads-platform-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  cpu    = 256
  memory = 512

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  # Fix: explicitly declare the runtime platform so Fargate
  # pulls the correct linux/amd64 image descriptor.
  # Previously omitted — causing the ARM64-only image to be rejected.
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"   # X86_64 = linux/amd64
  }

  container_definitions = jsonencode([
    {
      name  = "ads-platform"
      image = "442042537896.dkr.ecr.us-west-2.amazonaws.com/ads-platform:latest"

      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]

      environment = [
        {
          name  = "APP_ENV"
          value = "production"
        },
        {
          name  = "APP_HOST"
          value = "0.0.0.0"
        },
        {
          name  = "APP_PORT"
          value = "8000"
        }
      ]
    }
  ])
}
