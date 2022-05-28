# So we can extract the project number from the current project
data "google_project" "project" {
}

resource "random_password" "db_password" {
  length           = 12
  special          = true  # allow special characters
}

# Create secret with automatic replication
# Create secret value for DB PWD
module "secret-manager" {
  source     = "github.com/derailed-dash/cloud-foundation-fabric//modules/secret-manager?ref=v15.0.0"
  project_id = var.project_id
  secrets    = {
    db_pwd = null
  }
  versions = {
    db_pwd = {
      v1 = { enabled = true, data = random_password.db_password.result }
    }
  }

  iam = {
    db_pwd   = {
      "roles/secretmanager.secretAccessor" = ["group:gcp-organization-admins@just2good.co.uk",
                                              "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com",
                                              "serviceAccount:${local.project_name}-${local.project_suffix}@appspot.gserviceaccount.com"] # for cloud functions
    }
  }
}