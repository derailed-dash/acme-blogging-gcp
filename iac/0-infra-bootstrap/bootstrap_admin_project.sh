# Create our Terraform IaC project, and switch to it as default
gcloud projects create ${TF_VAR_admin_id} \
  --name ${TF_ADMIN_NAME} \
  --set-as-default \
  --folder ${TF_VAR_shared_folder_id}

# Link billing account
gcloud beta billing projects link ${TF_VAR_admin_id} \
  --billing-account ${TF_VAR_billing_account}

# Create service account that will be used for TF Admin
# terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com
# E.g. terraform@acme-infra-admin-6821.iam.gserviceaccount.com
gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"

# Obtain the JSON credentials in $TF_CREDS
# Will need to do this for any new shell instance
gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com

# Setup project-level permissions
gcloud projects add-iam-policy-binding ${TF_VAR_admin_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/owner

gcloud projects add-iam-policy-binding ${TF_VAR_admin_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/iap.admin

# Setup folder-level permissions
gcloud resource-manager folders add-iam-policy-binding ${TF_VAR_top_folder} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/secretmanager.secretAccessor

gcloud resource-manager folders add-iam-policy-binding ${TF_VAR_top_folder} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud resource-manager folders add-iam-policy-binding ${TF_VAR_top_folder} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectIamAdmin
  
gcloud resource-manager folders add-iam-policy-binding ${TF_VAR_top_folder} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/serviceusage.serviceUsageConsumer

gcloud resource-manager folders add-iam-policy-binding ${TF_VAR_top_folder} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/cloudsql.admin

gcloud resource-manager folders add-iam-policy-binding ${TF_VAR_top_folder} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/cloudkms.admin

gcloud resource-manager folders add-iam-policy-binding ${TF_VAR_top_folder} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/secretmanager.admin

gcloud resource-manager folders add-iam-policy-binding ${TF_VAR_top_folder} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/compute.xpnAdmin

# Setup org-level permissions
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/billing.admin

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/compute.xpnAdmin

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/resourcemanager.organizationViewer

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/accesscontextmanager.policyAdmin

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN_ID}.iam.gserviceaccount.com \
  --role roles/iam.securityAdmin

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN_ID}.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountAdmin

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/storage.admin

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN_ID}.iam.gserviceaccount.com \
  --role roles/resourcemanager.folderAdmin

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN_ID}.iam.gserviceaccount.com \
  --role roles/run.admin

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN_ID}.iam.gserviceaccount.com \
  --role roles/cloudfunctions.admin

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/compute.networkAdmin

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/logging.logWriter

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/monitoring.metricWriter

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com \
  --role roles/osconfig.guestPolicyAdmin
  
  

# Enable APIs in the admin project
# Some of these will be used for the Cloud-Build Project bootstrap later
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable serviceusage.googleapis.com
gcloud services enable monitoring.googleapis.com
gcloud services enable logging.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable sourcerepo.googleapis.com
gcloud services enable cloudkms.googleapis.com
gcloud services enable iamcredentials.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable admin.googleapis.com
gcloud services enable appengine.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable monitoring.googleapis.com
gcloud services enable pubsub.googleapis.com
gcloud services enable securitycenter.googleapis.com
gcloud services enable billingbudgets.googleapis.com
gcloud services enable iap.googleapis.com
gcloud services enable oslogin.googleapis.com

# Create Cloud Storage bucket, in this project, for managing all TF state
gsutil mb -p ${TF_VAR_admin_id} gs://${TF_VAR_admin_id}
# Enable versioning on the bucket
gsutil versioning set on gs://${TF_VAR_admin_id}
