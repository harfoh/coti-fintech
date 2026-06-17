output "app_url" {
  value       = "http://localhost:${var.app_port}"
  description = "Payment API URL"
}

output "nginx_url" {
  value       = "http://localhost:${var.nginx_port}"
  description = "Nginx reverse proxy URL"
}

output "health_check_url" {
  value       = "http://localhost:${var.app_port}/health"
  description = "Health check endpoint"
}

output "container_name" {
  value       = docker_container.coti_payment_api.name
  description = "Running container name"
}
