resource "aws_cloudwatch_log_group" "master" {
  name              = "/ecs/${var.project_name}/${var.env}/master"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/ecs/${var.project_name}/${var.env}/worker"
  retention_in_days = 30
}