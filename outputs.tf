output "application_url" {
  description = "The URL of the application"
  value = "http://${module.application.application_url}"
}