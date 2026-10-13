variable "vpc_id" {
  description = "The ID of the VPC where the RDS instance will be deployed"
  type        = string
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group to use for the RDS instance"
  type        = string
}

variable "app_subnets_cidr" {
  description = "The CIDR blocks of the layer app for permitting traffic inbound to port 3306"
  type        = list(string)
}

variable "db_name" {
  description = "The name of the RDS database"
  type        = string
}

variable "db_username" {
  description = "The username admin for the RDS database"
  type        = string
}

variable "db_password" {
  description = "The password for the RDS database (in real environments, consider using a AWS Secrets Manager)"
  type        = string
  sensitive   = true
}