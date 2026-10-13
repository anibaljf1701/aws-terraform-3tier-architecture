# 1. Security Group for the Load Balancer (public)
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
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

  tags = {
    Name = "alb-sg-3tier"
  }
}

# 2. Security Group for EC2 instances (private)
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow inbound traffic from the Load Balancer to the EC2 instances"
  vpc_id      = var.vpc_id

    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = [aws_security_group.alb_sg.id] # <-- Security key here
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0/0"] # Allow all outbound traffic by NAT gateway
    }

    tags = {
        Name = "ec2-sg-3tier"
    }
}

# 3. Application Load Balancer (ALB)
resource "aws_lb" "app_alb" {
  name               = "app-portfolio-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "app-portfolio-alb"
  }
}

# 4. Target Group (ALB send traffic here)
resource "aws_lb_target_group" "app_tg" {
  name     = "app-portfolio-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# 5. Listener (ALB listen to traffic)
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.app_alb.arn
    port              = "80"
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
  name_prefix = "portfolio-app-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

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

    tags = {
      Name = "portfolio-app-instance"
    }
  }  
}

# 8. Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-portfolio-asg"
  vpc_zone_identifier       = var.private_app_subnet_ids
  target_group_arns          = [aws_lb_target_group.app_tg.arn]

  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 1
  
  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}  