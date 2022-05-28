#######################################################################
# Networking 
#
# I'm using the GCP VPC module from 
# https://github.com/terraform-google-modules/terraform-google-network
# 
#######################################################################

module "vpc" {
    project_id = var.project_id
    source  = "terraform-google-modules/network/google"
    version = "~> 4.0"

    network_name = local.network
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = local.infra_subnet
            subnet_ip             = var.subnet_cidr_ranges.pri_private
            subnet_region         = var.regions.pri
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "Admin subnet"                        
        }
    ]

    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        }
    ]
}

#########
# Zones #
#########

data "google_compute_zones" "pri_zones" {
  region = var.regions.pri
}

####################################################################################
# NAT                                                                              #
#                                                                                  #
# So that our builder VM has access to the Internet without an external IP address #
####################################################################################

module "cloud_router" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4"
  project = var.project_id # Replace this with your project ID in quotes
  name    = "cloud-router"
  network = module.vpc.network_id
  region  = var.regions.pri

  nats = [{
    name = "nat-gateway"
  }]
}

###############
# Firewalling #
###############

# implicit allow-egress not overridden.

# allow traffic within the VPC
resource "google_compute_firewall" "allow_internal" {
  name          = "allow-internal"  
  network       = module.vpc.network_id
  direction     = "INGRESS"  

  allow {
    ports    = ["0-65535"]
    protocol = "tcp"
  }
  allow {
    ports    = ["0-65535"]
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  priority      = 65534
  source_ranges = values(var.subnet_cidr_ranges)
}

# only allow SSH to tagged instances, e.g. bastion
resource "google_compute_firewall" "inbound_ssh" {
  name          = "inbound-ssh"
  network       = module.vpc.network_id

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"

  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}