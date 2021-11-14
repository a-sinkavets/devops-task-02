data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_efs_file_system" "fs" {
  creation_token = "my-product"
  encrypted = true
}

resource "aws_efs_access_point" "access_point" {
  file_system_id = aws_efs_file_system.fs.id
}

resource "aws_efs_file_system_policy" "policy" {
  file_system_id = aws_efs_file_system.fs.id

  bypass_policy_lockout_safety_check = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "ExamplePolicy01",
    "Statement": [
        {
            "Sid": "ExampleStatement01",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.fs.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "true"
                }
            }
        }
    ]
}
POLICY
}

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

  ## Stil in developing ##
  # volume {
  #   name = "myEfsVol"
  #   efs_volume_configuration {
  #     file_system_id          = aws_efs_file_system.fs.id
  #     transit_encryption      = "ENABLED"
  #     transit_encryption_port = 2999
  #     authorization_config {
  #       access_point_id = aws_efs_access_point.access_point.id
  #       iam             = "DISABLED"
  #     }
  #   }
  # }
}

resource "aws_ecs_service" "service-01" {
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
