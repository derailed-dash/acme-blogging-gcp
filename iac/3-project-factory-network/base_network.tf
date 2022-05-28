#######################################################################
# Networking 
#
# I'm using the GCP VPC module from 
# https://github.com/terraform-google-modules/terraform-google-network
# 
#######################################################################

module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 4.0"

    project_id = var.project_id
    network_name = local.network
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = local.subnets.pri_private
            subnet_ip             = var.subnet_cidr_ranges.pri_private
            subnet_region         = var.regions.pri
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "Primary private subnet"                        
        },
        {
            subnet_name           = local.subnets.stb_private
            subnet_ip             = var.subnet_cidr_ranges.stb_private
            subnet_region         = var.regions.stb
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "Standby private subnet"
        },
        {
            subnet_name           = local.subnets.pri_public
            subnet_ip             = var.subnet_cidr_ranges.pri_public
            subnet_region         = var.regions.pri
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "Primary public subnet"
        },
        {
            subnet_name           = local.subnets.stb_public
            subnet_ip             = var.subnet_cidr_ranges.stb_public
            subnet_region         = var.regions.stb
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "Standby public subnet"
        },
        {
            subnet_name           = local.subnets.pri_serverless
            subnet_ip             = var.subnet_cidr_ranges.pri_serverless
            subnet_region         = var.regions.pri
        },
        {
            subnet_name           = local.subnets.stb_serverless
            subnet_ip             = var.subnet_cidr_ranges.stb_serverless
            subnet_region         = var.regions.stb
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

data "google_compute_zones" "stb_zones" {
  region = var.regions.stb
}

####################################################################################
# NAT                                                                              #
#                                                                                  #
# So that our builder VM has access to the Internet without an external IP address #
####################################################################################

module "cloud_router_pri" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4"
  project = var.project_id
  name    = "cloud-router-pri"
  network = module.vpc.network_id
  region  = var.regions.pri

  nats = [{
    name = "nat-gateway-pri"
  }]
}

module "cloud_router_stb" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 0.4"
  project = var.project_id
  name    = "cloud-router-stb"
  network = module.vpc.network_id
  region  = var.regions.stb

  nats = [{
    name = "nat-gateway-stb"
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

# allow access from health check ranges
resource "google_compute_firewall" "inbound_health_check" {
  name          = "lb-fw-allow-hc"
  network       = module.vpc.network_id
  direction     = "INGRESS"
  
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}

# Allow serverless capabilities to connect to networked resources, like Cloud SQL
# An implicit FW rule is created to allow ingress from the connector's subnet to all destinations in the network
# Machine instances are automatically tagged as 'vpc-connector'
# VPC connectors must go in their OWN /28 subnet
# Arguably don't need resilience on this, given it's not a business critical function; just a dev function
module "pri_serverless_connector" {
  source     = "terraform-google-modules/network/google//modules/vpc-serverless-connector-beta"
  project_id = var.project_id
  vpc_connectors = [{
      name        = "pri-serverless-vpc-conn"
      region      = var.regions.pri
      subnet_name = local.subnets.pri_serverless
      machine_type  = var.machine_types.micro   # The connector is made up of instances
      min_instances = 2   # Instances can scale out, but will never scale in. Alas, 2 is the minimum!
      max_instances = 3   # And this has to be greater than min!
    }
    # Uncomment to specify an ip_cidr_range
    #   , {
    #     name          = "central-serverless2"
    #     region        = "us-central1"
    #     network       = module.test-vpc-module.network_name
    #     ip_cidr_range = "10.10.11.0/28"
    #     subnet_name   = null
    #     machine_type  = "e2-standard-4"
    #     min_instances = 2
    #   max_instances = 7 }
  ]
}