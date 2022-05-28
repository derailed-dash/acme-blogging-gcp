# required variables
variable "billing_account" {}
variable "org_id" {}
variable "cb_gcr_bucket_id" {}
variable "cb_sa" {}
variable "app_prefix" {}

variable "org" {
  default = "ds"
}

variable "parent_folder_id" {
  type = map(string)
  description = "Parent folder where this project will be created"
}  

variable "env_cat" {
  type = map(string)
  description = "Whether a non-prod or prod environment"
}

variable "env_cat_short" {
  type = map(string)
  description = "Whether a np or prd environment"
}

# Var, in case we ever want to change regions
variable "regions" {
  type = map(string)
  default = {
    pri = "europe-west2"  # primary region - London
    stb = "europe-west4"  # standby region - Netherlands
  }
}

variable "monitoring_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the monitoring project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "monitoring_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the monitoring project."
  type        = string
  default     = null
}

variable "monitoring_project_budget_amount" {
  description = "The amount to use as the budget for the monitoring project."
  type        = number
  default     = 100
}