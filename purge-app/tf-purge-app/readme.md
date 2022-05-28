# Creating App Resources in the Project

Here we deploy Cloud Functions with Terraform.

Whilst we can run this manually, it is generally expected to be invoked from the Cloud Build CI/CD pipeline. This TF configuration deploys Cloud Functions using source code stored in Google Cloud Source Repos.

## Folder Contents

- The various TF files that make up the Terraform configuration
- The cloudbuild.yaml, in order to run this configuration from Cloud Build

## Steps

```bash
cd tf-purge-app
source ../iac/init_vars.sh
gcloud config set project ${TF_VAR_admin_id}
```

One-off:

Replace appropriate variables in `terraform.tfvars` using output variables from the previous steps.

```bash
# We need to point to state in the existing bucket:
cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_VAR_admin_id}"
   prefix  = "terraform/project-factory-funcs/state"
 }
}
EOF
```

At this point, if using this configuration as part of a CI/CD pipeline, it is expected that the purge-app folder is pushed (as a git repo) to the source repo.

## Manual Invoke

If running the TF manually:

```bash
terraform init

# Create workspaces to match previous. E.g.
terraform workspace new dev-1

# check we're in the right workspace. E.g.
terraform workspace select dev-1

# Optionally validate
terraform validate

terraform plan -out out.tfplan
terraform apply "out.tfplan"
```

## From Cloud Build as a Repo

