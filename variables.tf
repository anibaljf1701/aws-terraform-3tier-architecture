variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Project identifier used in compute resource names and tags"
  type        = string
  default     = "portfolio"
}

variable "environment" {
  description = "Deployment environment used in compute resource names and tags"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Additional tags applied to compute and database resources"
  type        = map(string)
  default     = {}
}

variable "instance_type" {
  description = "EC2 instance type for the application tier"
  type        = string
  default     = "t2.micro"
}

variable "asg_min_size" {
  description = "Minimum number of application instances"
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "Initial and desired number of application instances"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of application instances"
  type        = number
  default     = 3
}

variable "asg_cpu_target_value" {
  description = "Target average CPU utilization percentage for auto scaling"
  type        = number
  default     = 60
}

variable "private_app_subnet_cidr" {
  description = "Range of IPs the EC2 (necessary for the firewall of the DB) will use"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "portfoliodb"
}

variable "db_username" {
  description = "Admin username for the RDS database"
  type        = string
  default     = "admin"
}

variable "db_engine_version" {
  description = "MySQL engine version for RDS"
  type        = string
  default     = "8.0"
}

variable "db_instance_class" {
  description = "RDS DB instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated RDS storage in GiB"
  type        = number
  default     = 20
}

variable "db_backup_retention_days" {
  description = "Number of days to retain automated RDS backups"
  type        = number
  default     = 7
}

variable "db_storage_encrypted" {
  description = "Whether to encrypt RDS storage"
  type        = bool
  default     = true
}

variable "db_apply_immediately" {
  description = "Whether to apply RDS modifications immediately"
  type        = bool
  default     = false
}