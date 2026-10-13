variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets for the application Load Balancer"
  type        = list(string)
}

variable "private_app_subnet_ids" {
  description = "IDs of the private subnets for the Auto Scaling Group"
  type        = list(string)
}