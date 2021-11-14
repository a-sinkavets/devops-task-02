resource "aws_ecs_cluster" "cluster-01" {
  name = "cluster-01"
  capacity_providers = [ "FARGATE", "FARGATE_SPOT" ]

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "CustomEcsTaskExecutionRole"
  assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = {
            Service = "ecs-tasks.amazonaws.com"
          }
          Action    = "sts:AssumeRole"
          Sid       = ""
        }
      ]
    })
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

resource "aws_cloudwatch_log_group" "log_mytask" {
  name = "/ecs/mytask"
}

resource "aws_ecs_task_definition" "task-01" {
  depends_on = [aws_cloudwatch_log_group.log_mytask]
  family                    = "mytask"
  cpu                       = 1024
  memory                    = 2048
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
      {
        name      = "mycontainer"
        image     = "ghcr.io/a-sinkavets/bitcoin:0.21.0"
        essential = true
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-create-group  = "true"
            awslogs-group         = "/ecs/mytask"
            awslogs-region        = "us-east-1"
            awslogs-stream-prefix = "ecs"
          }
        }
      }
    ])

  volume {
    name = "myEfsVol"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.fs.id
      root_directory          = "/opt/data"
      authorization_config {
        iam             = "DISABLED"
      }
    }
  }
}

resource "aws_ecs_service" "service-01" {
  depends_on = [
    aws_efs_mount_target.mount_us_east_1a,
    aws_efs_mount_target.mount_us_east_1b,
    aws_efs_mount_target.mount_us_east_1c,
    aws_efs_mount_target.mount_us_east_1d,
    aws_efs_mount_target.mount_us_east_1e,
    aws_efs_mount_target.mount_us_east_1f
  ]
  name            = "service-01"
  cluster         = aws_ecs_cluster.cluster-01.id
  task_definition = aws_ecs_task_definition.task-01.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets           = data.aws_subnet_ids.subnets.ids
    assign_public_ip  = true
  }
}
