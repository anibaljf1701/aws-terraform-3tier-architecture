# 1. Security Group for the Load Balancer (public)
locals {
  resource_prefix = "${var.project_name}-${var.environment}"
  resource_tags = merge(var.common_tags, {
    Project     = var.project_name
    Environment = var.environment
  })
}

resource "aws_security_group" "alb_sg" {
  name        = "${local.resource_prefix}-alb-sg"
  description = "Allow inbound traffic HTTP from the internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.resource_tags, { Name = "${local.resource_prefix}-alb-sg" })
}

# 2. Security Group for EC2 instances (private)
resource "aws_security_group" "ec2_sg" {
  name        = "${local.resource_prefix}-app-sg"
  description = "Allow inbound traffic from the Load Balancer to the EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.resource_tags, { Name = "${local.resource_prefix}-app-sg" })
}

# 3. Application Load Balancer (ALB)
resource "aws_lb" "app_alb" {
  name               = "${local.resource_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = merge(local.resource_tags, { Name = "${local.resource_prefix}-alb" })
}

# 4. Target Group (ALB send traffic here)
resource "aws_lb_target_group" "app_tg" {
  name     = "${local.resource_prefix}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = merge(local.resource_tags, { Name = "${local.resource_prefix}-app-tg" })
}

# 5. Listener (ALB listen to traffic)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# 6. Launch AMI more recently for Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 7. Launch Template for EC2 instances
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${local.resource_prefix}-app-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = data.aws_ami.amazon_linux_2023.root_device_name

    ebs {
      encrypted             = true
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  # User Data to install and run a simple web server
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to the Portfolio Application</h1><p>Hostname: $(hostname -f)</p>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.resource_tags, { Name = "${local.resource_prefix}-app" })
  }
}

# 8. Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "app_asg" {
  name                      = "${local.resource_prefix}-app-asg"
  vpc_zone_identifier       = var.private_app_subnet_ids
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = local.resource_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]

    precondition {
      condition     = var.min_size <= var.desired_capacity && var.desired_capacity <= var.max_size
      error_message = "desired_capacity must be between min_size and max_size."
    }
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${local.resource_prefix}-cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name

  target_tracking_configuration {
    target_value = var.cpu_target_value

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}