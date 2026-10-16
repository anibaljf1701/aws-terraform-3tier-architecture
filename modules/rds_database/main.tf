# 1. Security Group for RDS Database
resource "aws_security_group" "rds_sg" {
  name        = "rds_security_group"
  description = "Allow inbound traffic to RDS database from the app layer"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow inbound traffic from the app layer to RDS database on port 3306"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic from RDS database"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "rds-sg-3tier"
  }
}

# 2. Instance RDS MySQL
resource "aws_db_instance" "main" {
  identifier        = "portfolio-db-instance"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Security configuration
  publicly_accessible = false
  skip_final_snapshot = true
  apply_immediately   = true

  tags = {
    Name = "portfolio-rds-mysql"
  }
}


