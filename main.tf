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
    bucket                      = "symphony-core-bucket"
    impersonate_service_account = "symphony-service@symphony-core-358423.iam.gserviceaccount.com"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

// https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service
resource "google_cloud_run_service" "default" {
  name     = "symphony-service"
  location = "us-west1" // https://cloud.google.com/run/docs/locations
  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}