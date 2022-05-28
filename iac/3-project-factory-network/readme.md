# Using the Project Factory to Create a Project

Here we create the VPC and subnets, create bastion hosts with IAP, and setup firewall rules.

## Steps

Create terraform spaces that match what was done in step 2.

```bash
cd iac/3-project-factory-network
source ../init_vars.sh
gcloud config set project ${TF_VAR_admin_id}
```

One-off:

```bash
# We need to point to state in the existing bucket. Repeat on any machine where we run this TF:
cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_VAR_admin_id}"
   prefix  = "terraform/project-factory-network/state"
 }
}
EOF
```

## Running the Project Factory

Add the project ID to the terraform.tfvars. Remember that for project IDs, we want the `project_id`, not `id` or `number`.

```bash
terraform init
terraform workspace new dev-1
```

And then, each time we want to build it:

```bash
# Check the workspace we're using.
terraform workspace list

# switch the desired workspace. E.g.
terraform workspace select dev-1

# Optionally validate
terraform validate

terraform plan -out prj.tfplan
terraform apply "prj.tfplan"

# Get the VPC ID
terraform output -raw vpc_network_id
```