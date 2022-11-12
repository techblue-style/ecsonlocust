resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-${var.env}-ecs-cluster"
}

resource "aws_ecs_task_definition" "master" {
  family = "locust-master"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  task_role_arn = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      "name": "locust-master",
      "image": "${var.ecr_repo_url}",
      "essential": true,
      "command": ["-f", "/scripts/sample.py", "--master"],
      "portMappings": [
        {
          "containerPort": 8089,
          "hostPort": 8089,
        },
        {
          "containerPort": 5557,
          "hostPort": 5557,
        },
        {
          "containerPort": 5558,
          "hostPort": 5558,
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "master",
          "awslogs-group": "${aws_cloudwatch_log_group.master.name}"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "master" {
  name            = "locust-master"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.master.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name   = "locust-master"
    container_port   = 8089
  }

  network_configuration {
    subnets          = [aws_subnet.subnet_a.id]
    security_groups  = [aws_security_group.master.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.master.arn
  }
}

resource "aws_security_group" "master" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project_name}-locust-master-sg"

  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port   = 5557
    to_port     = 5557
    protocol    = "tcp"
    security_groups = [aws_security_group.worker.id]
  }

  ingress {
    from_port   = 5558
    to_port     = 5558
    protocol    = "tcp"
    security_groups = [aws_security_group.worker.id]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "worker" {
  name            = "locust-worker"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_desired_count

  network_configuration {
    subnets          = [aws_subnet.subnet_a.id]
    security_groups  = [aws_security_group.worker.id]
    assign_public_ip = true
  }
}

resource "aws_security_group" "worker" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project_name}-locust-worker-sg"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "worker" {
  family = "locust-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.fargate_cpu}"
  memory                   = "${var.fargate_memory}"
  task_role_arn = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      "name": "locust-worker",
      "essential": true,
      "image": "${var.ecr_repo_url}",
      "command": ["-f", "/scripts/sample.py", "--worker", "--master-host=master.locust.internal"]
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-region": "ap-northeast-1",
          "awslogs-stream-prefix": "worker",
          "awslogs-group": "${aws_cloudwatch_log_group.worker.name}"
        }
      }
    }
  ])
}