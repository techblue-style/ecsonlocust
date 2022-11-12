output "endpoint" {
  value = "endpoint: http://${aws_lb.alb.dns_name}"
}
