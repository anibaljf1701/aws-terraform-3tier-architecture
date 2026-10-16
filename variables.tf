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
  description = "Additional tags applied to compute resources"
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

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
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