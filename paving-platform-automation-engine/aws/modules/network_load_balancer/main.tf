resource "aws_security_group" "load_balancer" {
  name        = var.name
  description = "Allows users to access the ${var.name}"
  vpc_id      = var.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = var.target_group_port
    to_port     = var.target_group_port
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
  }

  tags = var.tags
}

resource "aws_lb" "load_balancer" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "network"
  subnets            = var.public_subnet_ids

  timeouts {
    create = "20m"
  }

  tags = var.tags
}

resource "aws_lb_target_group" "load_balancer" {
  name     = var.name
  port     = var.target_group_port
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    protocol            = var.health_check_protocol
    path                = var.health_check_path
    port                = var.health_check_port
  }

  tags = var.tags
}

resource "aws_lb_listener" "load_balancer" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = var.listener_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.load_balancer.arn
  }
}
