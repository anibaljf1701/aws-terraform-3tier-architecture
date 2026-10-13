variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
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