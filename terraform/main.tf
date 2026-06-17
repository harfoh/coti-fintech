terraform {
  required_version = ">= 1.6.0"
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# ── Network ───────────────────────────────────────────────────────────────────
resource "docker_network" "coti_net" {
  name   = "coti-fintech-${var.env}-net"
  driver = "bridge"
}

# ── Images ────────────────────────────────────────────────────────────────────
resource "docker_image" "coti_payment_api" {
  name         = "${var.image_name}:${var.image_tag}"
  keep_locally = true
}

resource "docker_image" "nginx" {
  name         = "nginx:1.27-alpine"
  keep_locally = true
}

# ── Payment API container ─────────────────────────────────────────────────────
resource "docker_container" "coti_payment_api" {
  name  = "coti-payment-api-${var.env}"
  image = docker_image.coti_payment_api.image_id

  env = [
    "ENV=${var.env}",
    "APP_VERSION=${var.image_tag}"
  ]

  ports {
    internal = 8000
    external = var.app_port
  }

  networks_advanced {
    name = docker_network.coti_net.name
  }

  healthcheck {
    test         = ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]
    interval     = "30s"
    timeout      = "5s"
    retries      = 3
    start_period = "10s"
  }

  restart = "unless-stopped"

  log_driver = "json-file"
  log_opts = {
    "max-size" = "10m"
    "max-file" = "3"
  }

  must_run = true
}

# ── Nginx container ───────────────────────────────────────────────────────────
resource "docker_container" "nginx" {
  name  = "coti-nginx-${var.env}"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.nginx_port
  }

  volumes {
    host_path = abspath("${path.module}/../nginx/nginx.conf")
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.coti_net.name
  }

  restart    = "unless-stopped"
  depends_on = [docker_container.coti_payment_api]
}
