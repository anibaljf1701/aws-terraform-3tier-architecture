output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.app_alb.dns_name
}

output "app_security_group_id" {
  description = "The security group ID for application instances"
  value       = aws_security_group.ec2_sg.id
}