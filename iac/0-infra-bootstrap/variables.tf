variable "project_id" {}
variable "project_name" {}
variable "iap_groups" {
  type = list
}

# Var, in case we ever want to change regions
variable "regions" {
  type = map(string)
  default = {
    pri = "europe-west2"  # primary region - London
    stb = "europe-west4"  # standby region - Netherlands
  }
}

variable "subnet_cidr_ranges" {
  type = map(string)
  default = {
    pri_private = "192.168.1.0/24"
    stb_private = "192.168.2.0/24"
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
