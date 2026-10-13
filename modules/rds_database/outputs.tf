output "db_endpoint" {
  description = "The endpoint of connecting to the RDS database"
  value       = aws_db_instance.main.endpoint
}

output "db_port" {
  description = "The port of connecting to the RDS database"
  value       = aws_db_instance.main.port
}

