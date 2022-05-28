terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
    }
  }
}

provider "google" {   # This provider will be used by default
  # Credentials are pulled from GOOGLE_APPLICATION_CREDENTIALS env
  region   = var.regions.pri
}

provider "google-beta" {
  region  = var.regions.pri
}
