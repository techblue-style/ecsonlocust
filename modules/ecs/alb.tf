resource "aws_security_group" "alb" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project_name}-alb-sg"

  ingress {
    from_port   = 80
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name               = "${var.project_name}-alb-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.subnet_a.id, aws_subnet.subnet_c.id]
}

resource "aws_lb_target_group" "alb" {
  name        = "${var.project_name}-alb-target-group"
  port        = 8089
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    matcher             = "200,304"
    path                = "/"
  }

  depends_on = [aws_lb.alb] 
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb.arn
    type             = "forward"
  }
}