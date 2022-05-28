###########################################################################################
# Provision Cloud Functions                                                               #
# - posts_get_function                                                                    #                                
# - ghost_posts_purge                                                                     #
#                                                                                         #
# Passes in env variables that are picked up in the application code                      #
# Points to a serverless VPC connector, so that the functions can call the Cloud SQL DB   #
# Pulls the source code from Google Source Repos                                          #
###########################################################################################

data "google_compute_network" "vpc" {
  name = local.vpc_name
}

# Retrieve the secret value from Secret Manager
data "google_secret_manager_secret_version" "db_pwd" {
  secret = var.db_pwd
}

# Create HTTP function that shows the current posts
resource "google_cloudfunctions_function" "posts_get_function" {
    name              = "${var.app_prefix}-func-posts-get"
    runtime           = "python39"  # of course changeable
    region            = var.regions.pri
    trigger_http      = "true"
    entry_point       = "ghost_posts_get"
    vpc_connector     = local.vpc_connector
    ingress_settings  = "ALLOW_INTERNAL_ONLY"
    labels            = local.labels
    min_instances     = 0

    # Get the source repo; we expect the code to have already been put in the Cloud Source Repos
    source_repository {
      # e.g. https://source.developers.google.com/projects/${_CB_PROJECT}/repos/${_REPO_NAME}/moveable-aliases/master/paths/
      url             = var.src_repo
    }

    environment_variables = {
      db_conn_name    = var.db_conn_name   # e.g. "prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137"
      db_user         = "root"
      db_name         = local.db_name    # e.g. ghostdb
    }

    secret_environment_variables {  # this is a block; hence no "="
      key             = var.db_pwd
      secret          = local.pwd_secret_id
      version         = local.pwd_secret_version
    }  
}

# Create HTTP function that purges the current posts
resource "google_cloudfunctions_function" "posts_purge_function" {
    name              = "${var.app_prefix}-func-posts-purge"
    runtime           = "python39"  # of course changeable
    region            = var.regions.pri
    trigger_http      = "true"
    entry_point       = "ghost_posts_purge"
    vpc_connector     = local.vpc_connector
    ingress_settings  = "ALLOW_INTERNAL_ONLY"
    labels            = local.labels
    min_instances     = 0

    # Get the source repo; we expect the code to have already been put in the Cloud Source Repos
    source_repository {
      # e.g. https://source.developers.google.com/projects/${_CB_PROJECT}/repos/${_REPO_NAME}/moveable-aliases/master/paths/
      url             = var.src_repo
    }

    environment_variables = {
      db_conn_name    = var.db_conn_name   # e.g. "prj-ghost-dev-1-2eb70c61:europe-west2:ghostdb-2eb70c61-776137"
      db_user         = "root"
      db_name         = local.db_name    # e.g. ghostdb
    }

    secret_environment_variables {  # this is a block; hence no "="
      key             = var.db_pwd
      secret          = local.pwd_secret_id
      version         = local.pwd_secret_version
    }  
}

# Create Hello World HTTP function that we can demonstrate src changes with
resource "google_cloudfunctions_function" "hello_get_function" {
    name              = "${var.app_prefix}-func-hello-get"
    runtime           = "python39"  # of course changeable
    region            = var.regions.pri
    trigger_http      = "true"
    entry_point       = "hello_get"
    vpc_connector     = local.vpc_connector
    ingress_settings  = "ALLOW_INTERNAL_ONLY"
    labels            = local.labels
    min_instances     = 0

    # Get the source repo; we expect the code to have already been put in the Cloud Source Repos
    source_repository {
      # e.g. https://source.developers.google.com/projects/${_CB_PROJECT}/repos/${_REPO_NAME}/moveable-aliases/master/paths/
      url             = var.src_repo
    }
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "posts_get_invoker" {
  project        = google_cloudfunctions_function.posts_get_function.project
  region         = google_cloudfunctions_function.posts_get_function.region
  cloud_function = google_cloudfunctions_function.posts_get_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "posts_purge_invoker" {
  project        = google_cloudfunctions_function.posts_purge_function.project
  region         = google_cloudfunctions_function.posts_purge_function.region
  cloud_function = google_cloudfunctions_function.posts_purge_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "hello_get_invoker" {
  project        = google_cloudfunctions_function.hello_get_function.project
  region         = google_cloudfunctions_function.hello_get_function.region
  cloud_function = google_cloudfunctions_function.hello_get_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
