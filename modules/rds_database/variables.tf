variable "vpc_id" {
  description = "The ID of the VPC where the RDS instance will be deployed"
  type        = string
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group to use for the RDS instance"
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID of the application tier allowed to connect to MySQL"
  type        = string
}

variable "project_name" {
  description = "Project identifier used in RDS resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name used in RDS resource names and tags"
  type        = string
}

variable "common_tags" {
  description = "Additional tags applied to RDS resources"
  type        = map(string)
  default     = {}
}

variable "db_name" {
  description = "The name of the RDS database"
  type        = string
}

variable "db_username" {
  description = "The username admin for the RDS database"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,15}$", var.db_username))
    error_message = "db_username must start with a letter and contain only letters, numbers, or underscores, with a maximum length of 16 characters."
  }
}

variable "engine_version" {
  description = "MySQL engine version for the RDS instance"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "RDS DB instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated database storage in GiB"
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20
    error_message = "allocated_storage must be at least 20 GiB for this MySQL configuration."
  }
}

variable "max_allocated_storage" {
  description = "Optional maximum autoscaled database storage in GiB"
  type        = number
  default     = null
  nullable    = true

  validation {
    condition     = var.max_allocated_storage == null || var.max_allocated_storage >= var.allocated_storage
    error_message = "max_allocated_storage must be greater than or equal to allocated_storage."
  }
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups (0 disables automated backups)"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 0 and 35 days."
  }
}

variable "storage_encrypted" {
  description = "Whether to encrypt the RDS storage"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Whether to apply modifications immediately instead of waiting for the maintenance window"
  type        = bool
  default     = false
}