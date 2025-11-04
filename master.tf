terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket = "tf-state-UNICO"
    prefix = "envs/dev"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_web" {
  name                    = "vpc-web"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_web" {
  name          = "subnet-web"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc_web.id
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "fw-allow-http-https"
  network = google_compute_network.vpc_web.name
  allow { protocol = "tcp" ports = ["80","443"] }
  target_tags   = ["http-server"]     # amarrada a etiqueta
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm_web" {
  name         = "vm-web-1"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["http-server"]
  boot_disk { initialize_params { image = "projects/debian-cloud/global/images/family/debian-12" } }
  network_interface {
    subnetwork = google_compute_subnetwork.subnet_web.name
    access_config {}
  }
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    echo "<h1>Hello from Terraform + NGINX</h1>" > /var/www/html/index.nginx-debian.html
    systemctl enable nginx
    systemctl restart nginx
  EOT
}

output "vm_ip" {
  value = google_compute_instance.vm_web.network_interface[0].access_config[0].nat_ip
}
variables.tf
variable "project_id" { type = string }
variable "region"     { type = string  default = "us-central1" }
variable "zone"       { type = string  default = "us-central1-a" }
terraform.tfvars
project_id = "gcp-mod1-lab-gobierno"
region     = "us-central1"
zone       = "us-central1-a"
