# Creating App Resources in the Project

Here we deploy the load balancer, managed ssl certificate, managed instance group, health checks, GCE instances in the MIG, and deploy the application and Cloud SQL proxy to the instance, as containers.

## Steps

```bash
cd iac/5-app-infra-frontend
source ../init_vars.sh
gcloud config set project ${TF_VAR_admin_id}
```

One-off:

```bash
# We need to point to state in the existing bucket:
cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_VAR_admin_id}"
   prefix  = "terraform/project-factory-app-infra-frontend/state"
 }
}
EOF

terraform init

# Create workspaces to match previous. E.g.
terraform workspace new dev-1
```

## Running the Project Factory

Replace appropriate variables in `terraform.tfvars` using output variables from the previous steps.
Remember that for project IDs, we want the `project_id`, not `id` or `number`.

```bash
# check we're in the right workspace. E.g.
terraform workspace select dev-1

# Optionally validate
terraform validate

terraform plan -out out.tfplan
terraform apply "out.tfplan"
```