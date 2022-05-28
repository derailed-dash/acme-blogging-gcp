#######################################################################
# Just a collection of TF commands.
#
# Be sure to follow the pre-reqs...
#
# - Pull Terraform updates from Git
# - Check your env vars are correct
# - Make sure you're in the right admin project!
# - Change to your TF root module folder
# - Make sure you've properly setup your backend.tf in your root module
#
########################################################################

# Pull Terraform code from Git
# Change to the appropriate TF directory

# Reinitialise vars
source init_vars.sh

# Creating default credentials
gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com

# Creating default credentials in Docker CLI
gcloud iam service-accounts keys create ${CTR_CREDS} \
  --iam-account terraform@${TF_VAR_admin_id}.iam.gserviceaccount.com

# Make sure we also set our project to be the right infra-admin project
# gcloud config set project <prj_ID>
gcloud config set project ${TF_VAR_admin_id}

# Check workspace
terraform workspace list

# Create workspace.  E.g.
terraform workspace new dev-1

# Select workspace.  E.g.
terraform workspace select dev-1

# Initialise backend; you must run this from where tf files are hosted
terraform init

# Optionally validate
terraform validate

terraform plan -out out.tfplan 

terraform apply "out.tfplan"

# One hit
terraform destroy -auto-approve && terraform plan -out out.tfplan && terraform apply "out.tfplan"