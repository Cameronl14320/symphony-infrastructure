// Impersonation
// https://cloud.google.com/blog/topics/developers-practitioners/using-google-cloud-service-account-impersonation-your-terraform-code
provider "google" {
  alias = "impersonate"

  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

data "google_service_account_access_token" "default" {
  provider               = google.impersonate
  target_service_account = var.service_account
  scopes                 = ["userinfo-email", "cloud-platform"]
  lifetime               = "1200s"
}

provider "google" {
  access_token = data.google_service_account_access_token.default.access_token
  project      = var.project_id
}


// Getting started - https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started
terraform {
  backend "gcs" {
    bucket = "symphony-core-bucket"
    impersonate_service_account = var.service_account
  }
  required_providers {
    google = {
      source                      = "hashicorp/google"
    }
  }
}

resource "google_compute_instance" "vm_instance" {
  name         = "symphony-instance"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}