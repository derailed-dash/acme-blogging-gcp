# required variables
variable "app_prefix" {}
variable "domain" {}
variable "ghost_img" {}
variable "cloud_sql_proxy_img" {}
variable "project_id" {}
variable "vpc_id" {}
variable "db_conn_name" {}
variable "db_pwd" {
  default = "db_pwd"
}
variable "compute_sa_key" {
  default = "compute_sa_key"
}

variable "org" {
  default = "ds"
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

variable machine_type {
  type = map(string)
}

variable machine_images {
  type = map(string)
  default = {
    ubuntu_img = "ubuntu-os-cloud/ubuntu-2004-lts"
    debian_img = "debian-cloud/debian-10"
  }
}

variable "subnet_cidr_ranges" {
  type = map(string)
  default = {
    pri_private = "192.168.1.0/24"
    stb_private = "192.168.2.0/24"
    pri_public  = "192.168.3.0/24"
    stb_public  = "192.168.4.0/24"
  }
}

variable "num_read_replicas" {
  description = "The number of DB read replicas to create."
  type        = number
  default     = 1
}

variable "mig_instances" {
  type = map
}