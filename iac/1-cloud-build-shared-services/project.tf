##################################################
# Provision a new Cloud Build CI/CD project #
#
# Overview:
# - Create new project Cloud Build CI/CD project
# - Builds Terraform docker image for Cloud Build
# - Create GCS bucket for Cloud Build artefacts
# - Create Cloud Source Repos
#
##################################################

module "cloudbuild_bootstrap" {
  source  = "terraform-google-modules/bootstrap/google//modules/cloudbuild"
  version = "~> 5.0"

  org_id                         = var.org_id
  billing_account                = var.billing_account
  folder_id                      = var.shared_folder_id  # to host this project
  group_org_admins               = var.org_admins
  default_region                 = var.regions.pri

  terraform_sa_email             = local.tf_sa_email
  terraform_sa_name              = local.tf_sa_name
  sa_enable_impersonation        = true

  cloudbuild_plan_filename       = "cloudbuild-tf-plan.yaml"
  cloudbuild_apply_filename      = "cloudbuild-tf-apply.yaml"

  activate_apis                  = var.apis

  project_prefix                 = var.prefix
  terraform_state_bucket         = var.admin_id # bucket created previously
  
  project_labels = {
    environment       = "cicd"
    application_name  = "cicd"
  }
}

# Create a storage bucket that backs the GCR for this project
resource "google_container_registry" "registry" {
  project  = module.cloudbuild_bootstrap.cloudbuild_project_id
  location = "eu"
}

data "google_container_registry_repository" "gcr_repo" {
  project  = module.cloudbuild_bootstrap.cloudbuild_project_id
  region = "eu"
}

resource "google_project_iam_member" "project_source_reader" {
  project = module.cloudbuild_bootstrap.cloudbuild_project_id
  role    = "roles/source.writer"
  member  = "serviceAccount:${local.tf_sa_email}"

  depends_on = [module.cloudbuild_bootstrap.csr_repos]
}

data "google_project" "cloudbuild" {
  project_id = module.cloudbuild_bootstrap.cloudbuild_project_id

  depends_on = [module.cloudbuild_bootstrap.csr_repos]
}

######################################################################################
# Need the following roles on the Cloud Build Service Agent in order to run Cloud Run
######################################################################################

resource "google_organization_iam_member" "org_cb_sa_iam_viewer" {
  org_id = var.org_id
  role   = "roles/iam.securityReviewer"
  member = "serviceAccount:${data.google_project.cloudbuild.number}@cloudbuild.gserviceaccount.com"
}

resource "google_organization_iam_member" "org_cb_sa_browser" {
  org_id = var.org_id
  role   = "roles/browser"
  member = "serviceAccount:${data.google_project.cloudbuild.number}@cloudbuild.gserviceaccount.com"
}

resource "google_folder_iam_member" "folder_cb_sa_browser" {
  folder = var.top_folder
  role   = "roles/browser"
  member = "serviceAccount:${data.google_project.cloudbuild.number}@cloudbuild.gserviceaccount.com"
}

resource "google_folder_iam_member" "cloud_run_admin" {
  folder = var.top_folder
  role   = "roles/run.admin"
  member = "serviceAccount:${data.google_project.cloudbuild.number}@cloudbuild.gserviceaccount.com"
}

resource "google_folder_iam_member" "service_usage_consumer" {
  folder = var.top_folder
  role   = "roles/serviceusage.serviceUsageConsumer"
  member = "serviceAccount:${data.google_project.cloudbuild.number}@cloudbuild.gserviceaccount.com"
}

resource "google_folder_iam_member" "cb_secret_admin" {
  folder = var.top_folder
  role   = "roles/secretmanager.admin"
  member = "serviceAccount:${data.google_project.cloudbuild.number}@cloudbuild.gserviceaccount.com"
}

resource "google_folder_iam_member" "cb_network_admin" {
  folder = var.top_folder
  role   = "roles/compute.networkAdmin"
  member = "serviceAccount:${data.google_project.cloudbuild.number}@cloudbuild.gserviceaccount.com"
}

resource "google_organization_iam_member" "org_tf_compute_security_policy_admin" {
  org_id = var.org_id
  role   = "roles/compute.orgSecurityPolicyAdmin"
  member = "serviceAccount:${local.tf_sa_email}"
}

resource "google_folder_iam_member" "folder_tf_compute_security_policy_admin" {
  folder = var.top_folder
  role   = "roles/compute.orgSecurityPolicyAdmin"
  member = "serviceAccount:${local.tf_sa_email}"
}

resource "google_folder_iam_member" "secret_admin" {
  folder = var.top_folder
  role   = "roles/secretmanager.admin"
  member = "serviceAccount:${local.tf_sa_email}"
}

resource "google_folder_iam_member" "network_admin" {
  folder = var.top_folder
  role   = "roles/compute.networkAdmin"
  member = "serviceAccount:${local.tf_sa_email}"
}

resource "google_organization_iam_member" "org_tf_compute_security_resource_admin" {
  org_id = var.org_id
  role   = "roles/compute.orgSecurityResourceAdmin"
  member = "serviceAccount:${local.tf_sa_email}"
}

resource "google_folder_iam_member" "folder_tf_compute_security_resource_admin" {
  folder = var.top_folder
  role   = "roles/compute.orgSecurityResourceAdmin"
  member = "serviceAccount:${local.tf_sa_email}"
}
