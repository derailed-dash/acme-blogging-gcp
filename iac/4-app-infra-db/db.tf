# ------------------------------------------------------------------------------
# LAUNCH A MYSQL CLOUD SQL PRIVATE IP INSTANCE
#
# See https://github.com/gruntwork-io/terraform-google-sql/tree/master/modules/cloud-sql
# ------------------------------------------------------------------------------

#########
# Zones #
#########

data "google_compute_zones" "pri_zones" {
  region = var.regions.pri
}

data "google_compute_zones" "stb_zones" {
  region = var.regions.stb
}

# Project IDs must be unique. Here we generate a random project ID
# prefixed by project name
resource "random_id" "db_suffix" {
  byte_length = 3
}

# Reserve global internal address range for the peering
resource "google_compute_global_address" "private_ip_address" {
  project       = var.project_id
  provider      = google-beta
  name          = local.db_private_ip_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_id
}

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = var.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# ------------------------------------------------------------------------------
# CREATE DATABASE INSTANCE WITH PRIVATE IP
# ------------------------------------------------------------------------------

# TODO: Consider replacing with this: 
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance

module "mysql" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules. Check at...
  # source = "github.com/gruntwork-io/terraform-google-sql.git//modules/cloud-sql?ref=v0.6.0"
  source = "github.com/derailed-dash/terraform-google-sql//modules/cloud-sql?ref=fix-crash-safe-replication"
  
  project = var.project_id
  region  = var.regions.pri
  name    = "${local.db_instance_name}-${random_id.db_suffix.hex}"
  db_name = local.db_name

  engine       = var.mysql_version
  machine_type = var.db_machine_type[terraform.workspace]

  # Disabling deletion protection in non-prod layers.
  # Set to true to prevent accidental destruction of prod!
  deletion_protection = var.db_deletion_protection[terraform.workspace]

  # These together will construct the master_user privileges, i.e.
  # 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'.
  master_user_name = var.db_master_user_name
  master_user_password = random_password.db_password.result
  master_user_host = "%"

  # Pass the private network link to the module
  private_network = var.vpc_id
  
  # Note: this is legacy HA configuration mode. The current standard simply requires deploying as a regional instance.
  num_read_replicas  = var.num_read_replicas  # needs to match number of zones below
  read_replica_zones = [data.google_compute_zones.pri_zones.names[1]]  # expects a list of zones 
  
  custom_labels = merge(local.labels, {
    "type" = "sql-db"
  })

  # Wait for the vpc connection to complete
  dependencies = [google_service_networking_connection.private_vpc_connection.network]
}