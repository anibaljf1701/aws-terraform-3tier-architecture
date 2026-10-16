variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "project_name" {
  description = "Project identifier used in resource names and tags"
  type        = string
  default     = "portfolio"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.project_name)) && length(var.project_name) <= 14
    error_message = "project_name must start and end with a lowercase letter or number, contain only lowercase letters, numbers, and hyphens, and be at most 14 characters."
  }
}

variable "environment" {
  description = "Environment name used in resource names and tags"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.environment)) && length(var.environment) <= 10
    error_message = "environment must start and end with a lowercase letter or number, contain only lowercase letters, numbers, and hyphens, and be at most 10 characters."
  }
}

variable "common_tags" {
  description = "Additional tags applied to resources"
  type        = map(string)
  default     = {}
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets for the application Load Balancer"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "The public ALB subnets must include at least two subnets in different Availability Zones."
  }
}

variable "private_app_subnet_ids" {
  description = "IDs of the private subnets for the Auto Scaling Group"
  type        = list(string)

  validation {
    condition     = length(var.private_app_subnet_ids) > 0
    error_message = "At least one private application subnet is required."
  }
}

variable "attach_target_group_arns" {
  description = "Whether to associate the Auto Scaling Group with the ALB target group"
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type used by the application Auto Scaling Group"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Optional AMI ID override for local emulators or custom images"
  type        = string
  default     = null
  nullable    = true
}

variable "ami_root_device_name" {
  description = "Root device name used when ami_id is specified"
  type        = string
  default     = "/dev/xvda"
}

variable "min_size" {
  description = "Minimum number of application instances"
  type        = number
  default     = 1

  validation {
    condition     = var.min_size >= 1
    error_message = "min_size must be at least 1 to keep the application available."
  }
}

variable "desired_capacity" {
  description = "Initial and desired number of application instances"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of application instances"
  type        = number
  default     = 3

  validation {
    condition     = var.max_size >= 1
    error_message = "max_size must be at least 1."
  }
}

variable "cpu_target_value" {
  description = "Target average CPU utilization percentage for target tracking"
  type        = number
  default     = 60

  validation {
    condition     = var.cpu_target_value > 0 && var.cpu_target_value <= 100
    error_message = "cpu_target_value must be greater than 0 and no more than 100."
  }
}