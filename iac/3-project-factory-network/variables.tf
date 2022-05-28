# required variables
variable "project_id" {}
variable "app_prefix" {}
variable "iap_groups" {
  type = list
}


variable "env_cat" {
  type = map(string)
  description = "Whether a non-prod or prod environment"
}

# Var, in case we ever want to change regions
variable "regions" {
  type = map(string)
  default = {
    pri = "europe-west2"  # primary region - London
    stb = "europe-west4"  # standby region - Netherlands
  }
}

variable machine_types {
  type = map(string)
  default = {
    micro = "e2-micro" # shared-core, 2 (0.25) vCPU, 1GB
    small = "e2-small" # cost-optimised, 2 vCPU, 2GB
    med = "n2-standard-2" # balanced, 2 vCPU, 8GB    
  }
}

variable machine_images {
  type = map(string)
  default = {
    ubuntu_img = "ubuntu-minimal-1804-bionic-v20220331"
    debian_img = "debian-cloud/debian-10"
  }
}

variable mig_instances {
  type = map(number)
}

variable "subnet_cidr_ranges" {
  type = map(string)
  default = {
    pri_private = "192.168.1.0/24"
    stb_private = "192.168.2.0/24"
    pri_public  = "192.168.3.0/24"
    stb_public  = "192.168.4.0/24"
    pri_serverless = "10.0.1.0/28"
    stb_serverless = "10.0.2.0/28"
  }
}