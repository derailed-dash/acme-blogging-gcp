###########################
# Provision a new project #
###########################

# Project IDs must be unique. Here we generate a random project ID
# prefixed by project name
resource "random_id" "project_suffix" {
  byte_length = 4
}

# Create new project, and bind to org ID and billing account
resource "google_project" "project" {
  name            = local.project_name
  project_id      = "${local.project_name}-${random_id.project_suffix.hex}"
  billing_account = var.billing_account
  folder_id       = var.parent_folder_id[terraform.workspace]  # folder and org IDs are mutually exclusive
  labels = {
    environment       = terraform.workspace
    application_name  = var.app_prefix
  }
}

# Which APIs we want to enable in the new project
resource "google_project_service" "service" {
  project         = google_project.project.project_id
  
  for_each = toset([
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "storage-api.googleapis.com",    
    "cloudresourcemanager.googleapis.com", 
    "run.googleapis.com", # Cloud Run
    "container.googleapis.com",
    "cloudbuild.googleapis.com", # Cloud Build
    "containerregistry.googleapis.com", # GCR
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "iap.googleapis.com",
    "oslogin.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudfunctions.googleapis.com",
    "vpcaccess.googleapis.com"  # to connect to VPC from serverless environments, like Cloud Functions
  ])

  service = each.key
  disable_on_destroy = false
}

# Create secret with automatic replication
# Create secret to store compute service account key
module "secret-manager" {
  source     = "github.com/derailed-dash/cloud-foundation-fabric//modules/secret-manager?ref=v15.0.0"
  project_id = google_project.project.project_id
  secrets    = {
    compute_sa_key = null
  }
  versions = {
    compute_sa_key = {
      # The private key is base64 encoded. We can decode it to get a nice friendly json file, 
      # like 'cloud iam service-accounts keys create' would generate.
      v1 = { enabled = true, data = base64decode(google_service_account_key.sa_cred_key.private_key) }
    }
  }

  iam = {
    compute_sa_key   = {
      "roles/secretmanager.secretAccessor" = ["group:gcp-organization-admins@just2good.co.uk",
                                              "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"]
    }
  }

  depends_on = [google_project_service.service]
}

# Create a storage bucket for this project
module "bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"

  name       = "bkt-src-${local.project_suffix}"
  project_id = google_project.project.project_id
  location   = var.regions.pri

  iam_members = [{
    role   = "roles/storage.objectAdmin"
    member = "serviceAccount:${var.cb_sa}" # Allow CB SA to read and write to this project's src bucket
  }]

  depends_on = [google_project_service.service]
}

# Give access to service-<this-prj-id>@serverless-robot-prod.iam.gserviceaccount.com
resource "google_storage_bucket_iam_member" "viewer" {
  bucket = var.cb_gcr_bucket_id
  role = "roles/storage.objectViewer"
  member = "serviceAccount:service-${google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

# Allow Compute SA account to view the GCR bucket in the CI/CD project
resource "google_storage_bucket_iam_member" "compute_sa_viewer" {
  bucket = var.cb_gcr_bucket_id
  role = "roles/storage.objectViewer"
  member = "serviceAccount:${google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Get the default Compute Engine service account
data "google_service_account" "compute_sa" {
  project = google_project.project.project_id
  account_id = "${google_project.project.number}-compute@developer.gserviceaccount.com"
}

# Create SA credentials, which we'll store in a secret
resource "google_service_account_key" "sa_cred_key" {
  service_account_id = data.google_service_account.compute_sa.name
}

# Add Cloud Build SA as a serviceAccountUser of the Compute Engine SA within this project
resource "google_service_account_iam_binding" "compute_sa_account_user" {
  service_account_id = data.google_service_account.compute_sa.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${var.cb_sa}"
  ]
}

# Get the default App Engine service account
data "google_service_account" "appengine_sa" {
  project = google_project.project.project_id
  account_id = "${google_project.project.project_id}@appspot.gserviceaccount.com"
}

# Add Cloud Build SA as a serviceAccountUser of the App Engine SA within this project
resource "google_service_account_iam_binding" "appengine_sa_account_user" {
  service_account_id = data.google_service_account.appengine_sa.name
  role               = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:${var.cb_sa}"
  ]
}

# Add any other iam policy bindings that the CB_SA might requre in this project, e.g.
# cloudfunctions.developer, pubsub.editor, storage.admin, container.developer, datastore.user...
resource "google_project_iam_member" "project_source_reader" {
  project = google_project.project.project_id
  role    = "roles/cloudfunctions.admin"
  member  = "serviceAccount:${var.cb_sa}"
}

module "monitoring_project" {
  source                      = "terraform-google-modules/project-factory/google"
  random_project_id           = "true"
  name                        = "prj-${var.app_prefix}-${var.env_cat_short[terraform.workspace]}-monitoring"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.parent_folder_id[terraform.workspace]  # folder and org IDs are mutually exclusive

  disable_services_on_destroy = false
  activate_apis = [
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "billingbudgets.googleapis.com"
  ]

  labels = {
    environment       = terraform.workspace
    application_name  = var.app_prefix
    category          = "monitoring"
  }

  budget_alert_pubsub_topic   = var.monitoring_project_alert_pubsub_topic
  budget_alert_spent_percents = var.monitoring_project_alert_spent_percents
  budget_amount               = var.monitoring_project_budget_amount
}