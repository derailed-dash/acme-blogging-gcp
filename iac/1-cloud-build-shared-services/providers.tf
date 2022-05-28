terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {   # This provider will be used by default
  # Credentials are pulled from GOOGLE_APPLICATION_CREDENTIALS env
  region   = var.regions.pri
}

provider "google-beta" {
  region   = var.regions.pri
}
