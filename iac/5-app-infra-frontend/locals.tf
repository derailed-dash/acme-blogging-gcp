locals {
  vpc_name = element(split("/", var.vpc_id), length(split("/", var.vpc_id))-1)  # after the last /
  domain_prefix = element(split(".", var.domain), 0)  # before the first .
  project_name = lower("prj-${var.app_prefix}-${terraform.workspace}")
  project_suffix = element(split("-", var.project_id), length(split("-", var.project_id))-1)  # after the last -
  network = "${terraform.workspace}-vpc"
  
  domains = ["${var.domain}", 
             "${terraform.workspace}.${var.domain}"]  # needs to end in .

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

  google_load_balancer_ip_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]

  # Add in ssh if we want to do any direct access to the backend instances
  tags = ["allow-health-check", "http"]
}