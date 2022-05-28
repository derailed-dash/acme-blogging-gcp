app_prefix = "ghost"
project_id = "<CHANGE_ME>"  # We want the `project_id`, not `id` or `number`. E.g. prj-ghost-dev-1-2eb70c62
vpc_id = "<CHANGE_ME>"      # e.g. "projects/prj-ghost-dev-1-2eb70c62/global/networks/dev-1-vpc"

env_cat = {
  dev-1 = "non-prod"
  uat = "non-prod"
  prod = "prod"
}

db_deletion_protection = {  # do we want to delete the DB when we destroy the environment?
  dev-1 = false
  uat = false
  prod = true
}

db_machine_type = {
  dev-1 = "db-f1-micro"
  uat = "db-g1-small"
  prod = "db-g1-small"
}