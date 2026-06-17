variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "image_name" {
  description = "Full image name"
  type        = string
  default     = "coti-fintech-payment-api"
}

variable "app_port" {
  description = "Host port for the application"
  type        = number
  default     = 8000
}

variable "nginx_port" {
  description = "Host port for nginx"
  type        = number
  default     = 80
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "staging"
}
