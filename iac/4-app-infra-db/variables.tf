# required variables
variable "app_prefix" {}
variable "project_id" {}
variable "vpc_id" {}
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

variable "subnet_cidr_ranges" {
  type = map(string)
  default = {
    pri_private = "192.168.1.0/24"
    stb_private = "192.168.2.0/24"
    pri_public  = "192.168.3.0/24"
    stb_public  = "192.168.4.0/24"
  }
}

variable "mysql_version" {
  description = "The engine version of the database, e.g. `MYSQL_5_7`."
  type        = string
  default     = "MYSQL_5_7"
  # default     = "MYSQL_8_0"
}

variable "db_deletion_protection" {
  type = map
}

variable "db_machine_type" {
  type        = map
}

variable "db_master_user_name" {
  description = "The username part for the default user credentials, i.e. 'master_user_name'@'master_user_host' IDENTIFIED BY 'master_user_password'. This should typically be set as the environment variable TF_VAR_master_user_name so you don't check it into source control."
  type        = string
  default     = "root"  
}

variable "num_read_replicas" {
  description = "The number of DB read replicas to create."
  type        = number
  default     = 1
}