# Cloud Build CI/CD Project Setup

Here we create a project for hosting the Cloud Build pipeline.  It adds appropriate roles, and also creates a bucket to underpin the shared Google Container Repo.

## Steps

```bash
cd iac/1-cloud-build-shared-services
source ../init_vars.sh
gcloud config set project ${TF_VAR_admin_id}

# We need to point to state in the existing bucket. Repeat on any client where we run TF.
cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_VAR_admin_id}"
   prefix  = "terraform/cloud-build-ci/state"
 }
}
EOF

terraform init
terraform validate

terraform plan -out out.tfplan
terraform apply "out.tfplan"
```

The output looks something like this:

```text
cb_project_id = "cb-cloudbuild-6a53"
cb_sa = "800117839038@cloudbuild.gserviceaccount.com"
gcr_bucket_id = "eu.artifacts.cb-cloudbuild-6a53.appspot.com"
gcr_url = "eu.gcr.io/cb-cloudbuild-6a53"
```

Finally, enable vulnerability scanning on the new GCR through the Console.