# required variables
variable "app_prefix" {}
variable "project_id" {}
variable "src_repo" {}
variable "vpc_id" {}
variable "serverless_connector" {}
variable "db_conn_name" {}
variable "db_pwd" {
  default = "db_pwd"
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