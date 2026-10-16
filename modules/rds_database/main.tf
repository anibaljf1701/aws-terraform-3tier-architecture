locals {
  resource_prefix = "${var.project_name}-${var.environment}"
  db_identifier   = "${local.resource_prefix}-db"
  resource_tags = merge(var.common_tags, {
    Project     = var.project_name
    Environment = var.environment
  })
}

# 1. Security Group for RDS Database
resource "aws_security_group" "rds_sg" {
  name        = "${local.resource_prefix}-rds-sg"
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
    Name        = "${local.resource_prefix}-rds-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

# 2. Instance RDS MySQL
resource "aws_db_instance" "main" {
  identifier                  = local.db_identifier
  engine                      = "mysql"
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_encrypted           = var.storage_encrypted
  backup_retention_period     = var.backup_retention_period
  manage_master_user_password = true

  db_name  = var.db_name
  username = var.db_username

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Security configuration
  publicly_accessible = false
  skip_final_snapshot = true
  apply_immediately   = var.apply_immediately

  tags = merge(local.resource_tags, { Name = local.db_identifier })

  lifecycle {
    precondition {
      condition     = length(local.db_identifier) <= 63 && can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", local.db_identifier)) && !strcontains(local.db_identifier, "--")
      error_message = "The project/environment combination must produce a valid RDS identifier of at most 63 characters, starting with a letter and without consecutive or trailing hyphens."
    }
  }
}


