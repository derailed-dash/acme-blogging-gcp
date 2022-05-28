locals {
  project_name = lower("prj-${var.app_prefix}-${terraform.workspace}")
  network = "${terraform.workspace}-vpc"
  
  subnets = {
    pri_private = "${terraform.workspace}-subnet-pri-private"
    pri_public = "${terraform.workspace}-subnet-pri-public"
    stb_private = "${terraform.workspace}-subnet-stb-private"
    stb_public = "${terraform.workspace}-subnet-stb-public"
    pri_serverless = "${terraform.workspace}-subnet-pri-serverless"
    stb_serverless = "${terraform.workspace}-subnet-stb-serverless"
  }

  labels = {
    "prj"       = local.project_name
    "env"       = terraform.workspace
    "env-cat"   = "${var.env_cat[terraform.workspace]}"
    "application" = "${var.app_prefix}"
  }
}