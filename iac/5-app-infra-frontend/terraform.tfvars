app_prefix = "ghost"
domain = "acme-blogging.just2good.co.uk.co.uk"
ghost_img = "eu.gcr.io/cb-cloudbuild-6a53/dazbo-ghost:0.1"   # Repo address, e.g. "eu.gcr.io/cb-cloudbuild-6a53/dazbo-ghost:0.1" or "gcr.io/google-samples/hello-app:1.0"
cloud_sql_proxy_img = "eu.gcr.io/cloudsql-docker/gce-proxy:1.28.0" # E.g. eu.gcr.io/cloudsql-docker/gce-proxy:1.28.0
project_id = "prj-ghost-dev-1-2eb70c62"  # We want the `project_id`, not `id` or `number`. E.g. prj-ghost-dev-1-2eb70c62
vpc_id = "projects/prj-ghost-dev-1-2eb70c62/global/networks/dev-1-vpc"      # e.g. "projects/prj-ghost-dev-1-2eb70c62/global/networks/dev-1-vpc"
db_conn_name = "prj-ghost-dev-1-2eb70c62:europe-west2:ghostdb-2eb70c62-776138" # e.g. "prj-ghost-dev-1-2eb70c62:europe-west2:ghostdb-2eb70c62-776138"

env_cat = {
  dev-1 = "non-prod"
  uat = "non-prod"
  prod = "prod"
}

machine_type = {
  dev-1 = "e2-standard-2" # cost-optimised, 2 vCPU, 8GB
  uat = "e2-standard-2" # cost-optimised, 2 vCPU, 8GB
  prod = "n2-standard-2" # balanced, 2 vCPU, 8GB - offers sustained use discount   
}

mig_instances = {  # If we're setting explicitly, and not using auto scaler
  dev-1 = 2
  uat = 3
  prod = 3
}