locals {
  project_suffix = element(split("-", var.project_id), length(split("-", var.project_id))-1)
  vpc_name = element(split("/", var.vpc_id), length(split("/", var.vpc_id))-1)
  project_name = lower("prj-${var.app_prefix}-${terraform.workspace}")
  network = "${terraform.workspace}-vpc"
  
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
    "application" = "${var.app_prefix}"
  }

  db_name = "${var.app_prefix}db"  # Ghost doesn't like a hyphen in the DB name
  db_instance_name        = "${local.db_name}-${local.project_suffix}"
  db_private_network_name = "db-network-${local.project_suffix}"
  db_private_ip_name      = "db-private-ip-${local.project_suffix}"
}