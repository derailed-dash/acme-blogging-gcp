locals {
  project_name      = lower("prj-${var.app_prefix}-${terraform.workspace}")
  project_suffix    = element(split("-", var.project_id), length(split("-", var.project_id))-1)  # after the last -
  network           = "${terraform.workspace}-vpc"
  vpc_name          = element(split("/", var.vpc_id), length(split("/", var.vpc_id))-1)  # after the last /  
  db_name           = "${var.app_prefix}db"  # Ghost doesn't like a hyphen in the DB name
  vpc_connector     = "projects/${var.project_id}/locations/${var.regions.pri}/connectors/${var.serverless_connector}"

  subnets = {
    pri_private = "${terraform.workspace}-subnet-pri-private"
    pri_public = "${terraform.workspace}-subnet-pri-public"
    stb_private = "${terraform.workspace}-subnet-stb-private"
    stb_public = "${terraform.workspace}-subnet-stb-public"
  }

  labels = {
    "prj"       = local.project_name
    "env"       = terraform.workspace
    "env-cat"   = "${var.env_cat[terraform.workspace]}"
    "application" = "${var.app_prefix}-purge"
  }

  # secret like: projects/197270889644/secrets/db_pwd/versions/1
  pwd_secret_id = element(split("/", data.google_secret_manager_secret_version.db_pwd.name), 3) # e.g. db_pwd
  pwd_secret_version =   element(split("/", data.google_secret_manager_secret_version.db_pwd.name), length(split("/", data.google_secret_manager_secret_version.db_pwd.name))-1) # e.g. 1
}