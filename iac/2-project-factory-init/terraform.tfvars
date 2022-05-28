app_prefix = "ghost"

cb_gcr_bucket_id = "<CHANGE_ME>" # e.g. "eu.artifacts.cb-cloudbuild-6a54.appspot.com"
cb_sa = "<CHANGE_ME>"   # e.g. 800117839039@cloudbuild.gserviceaccount.com

parent_folder_id = {
  dev-1 = "<CHANGE_ME>" # e.g. "713338487122"
  uat = "<CHANGE_ME>"   # e.g. "713338487122"
  prod = "<CHANGE_ME>"  # e.g. "1049973940465"
}

env_cat = {
  dev-1 = "non-prod"
  uat = "non-prod"
  prod = "prod"
}

env_cat_short = {
  dev-1 = "np"
  uat = "np"
  prod = "prd"
}
