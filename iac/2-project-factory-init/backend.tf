terraform {
 backend "gcs" {
   bucket  = "acme-infra-admin-6821"
   prefix  = "terraform/cloud-build-ci/state"
 }
}
