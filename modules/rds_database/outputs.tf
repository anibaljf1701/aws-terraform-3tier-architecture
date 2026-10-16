output "db_endpoint" {
  description = "The endpoint of connecting to the RDS database"
  value       = aws_db_instance.main.endpoint
}

output "db_port" {
  description = "The port of connecting to the RDS database"
  value       = aws_db_instance.main.port
}

output "db_master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the RDS master credentials"
  value       = try(aws_db_instance.main.master_user_secret[0].secret_arn, null)
}

