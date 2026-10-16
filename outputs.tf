output "application_url" {
  description = "The URL of the application"
  value       = "http://${module.compute.alb_dns_name}"
}

output "database_endpoint" {
  description = "The RDS database endpoint"
  value       = module.database.db_endpoint
}

output "database_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the RDS master credentials"
  value       = module.database.db_master_user_secret_arn
}