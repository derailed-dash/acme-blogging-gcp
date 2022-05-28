app_prefix = "ghost"
project_id = "<CHANGE_ME>"  # We want the `project_id`, not `id` or `number`. E.g. prj-ghost-dev-1-2eb70c62

env_cat = {
  dev-1 = "non-prod"
  uat = "non-prod"
  prod = "prod"
}

iap_groups = [
    "group:gcp-organization-admins@just2good.co.uk",
    "group:gcp-developers@just2good.co.uk",
    "group:gcp-devops@just2good.co.uk"
]

mig_instances = {
  dev-1 = 2
  uat = 3
  prod = 3
}