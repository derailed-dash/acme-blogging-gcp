app_prefix = "ghost"
project_id = "prj-ghost-dev-1-2eb70c62"  # We want the `project_id`, not `id` or `number`. E.g. prj-ghost-dev-1-2eb70c62
vpc_id = "projects/prj-ghost-dev-1-2eb70c62/global/networks/dev-1-vpc"      # e.g. "projects/prj-ghost-dev-1-2eb70c62/global/networks/dev-1-vpc"
serverless_connector = "pri-serverless-vpc-conn"
db_conn_name = "prj-ghost-dev-1-2eb70c62:europe-west2:ghostdb-2eb70c62-776137" # e.g. "prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c62-776137"
src_repo = "https://source.developers.google.com/projects/cb-cloudbuild-6a54/repos/ghost-purge-app/moveable-aliases/master/paths/"

env_cat = {
  dev-1 = "non-prod"
  uat = "non-prod"
  prod = "prod"
}
