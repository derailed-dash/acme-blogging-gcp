# required variables
variable "billing_account" {}
variable "org_id" {}
variable "admin_id" {}
variable "top_folder" {}
variable "shared_folder_id" {}
variable "org_admins" {}
variable "prefix" {}

variable "apis" {
  type = list(string)
}

variable "org" {}

# Var, in case we ever want to change regions
variable "regions" {
  type = map(string)
  default = {
    pri = "europe-west2"  # primary region - London
    stb = "europe-west4"  # standby region - Netherlands
  }
}
