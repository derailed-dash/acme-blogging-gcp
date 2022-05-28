# Using the Project Factory to Create a Project

Here we create a target (e.g. Dev) project, enable APIs, enable secret manager, and allow the Cloud Run service agent to view the shared GCR.

## Steps

Create terraform workspaces, for each environment we want to manage. 
Check the `terraform.tfvars` file for allowed environments.

```bash
cd iac/2-project-factory-init
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
   prefix  = "terraform/project-factory-init/state"
 }
}
EOF
```

## Running the Project Factory

If the environment is new:

```bash
terraform init
terraform workspace new dev-1
```

And then, each time we want to build it:

```bash
# switch the desired workspace. E.g.
terraform workspace select dev-1

# Optionally validate
terraform validate

terraform plan -out prj.tfplan
terraform apply "prj.tfplan"
```

The output looks like this:

```text
project_info = {
  "auto_create_network" = true
  "billing_account" = "012345-6789AB-CDEF01"
  "folder_id" = "713338487121"
  "id" = "projects/prj-ghost-dev-1-2eb70c61"
  "labels" = tomap({})
  "name" = "prj-ghost-dev-1"
  "number" = "197270889644"
  "org_id" = ""
  "project_id" = "prj-ghost-dev-1-2eb70c61"
  "skip_delete" = tobool(null)
  "timeouts" = null /* object */
}
project_suffix = "2eb70c61"
```

We can always get specific output elements like this:

```bash
# Get the project info.  You'll need the project ID for the next step. (Not the number!!)
terraform output -raw project_info

# Get the random project suffix
terraform output -raw project_suffix
```