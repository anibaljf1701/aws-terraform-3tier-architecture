output "vpc_id" {
  description = "Ministack VPC resource ID"
  value       = module.vpc.vpc_id
}

output "application_url" {
  description = "Emulated ALB URL (metadata/data-plane limitations apply)"
  value       = "http://${module.compute.alb_dns_name}"
}

output "database_endpoint" {
  description = "Host endpoint for the real local MySQL container"
  value       = module.database.db_endpoint
}

output "database_secret_arn" {
  description = "ARN of the emulated Secrets Manager secret for RDS credentials"
  value       = module.database.db_master_user_secret_arn
}
