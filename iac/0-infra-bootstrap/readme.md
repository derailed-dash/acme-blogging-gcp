# Bootstrap the Terraform Project Factory

Here we create the Terraform bootstrap project and service account, assign roles, enable APIs, and provision the bucket that will be used for Terraform state.

## Steps

Pull the repo.  Then:

```bash
cd iac/0-infra-bootstrap

# Configure variables for this org and for unique project IDs
source ../init_vars.sh

# Now run the bootstrap
sh ./boostrap_admin_project.sh

```bash
# We need to point to state in the existing bucket:
cat > backend.tf << EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_VAR_admin_id}"
   prefix  = "terraform/infra-boostrap/state"
 }
}
EOF
```

Now that we've boostrapped our Terraform, we can use TF to create an Infra VM for performing subsequent TF activity.
(This saves us having to use Cloud Shell, or installing on local machines.)

```bash
terraform init
terraform plan -out prj.tfplan
terraform apply "prj.tfplan"
```

## Boostrap Setup On A Second Client

Pull the repo.  Change to the infra folder. Then:

```bash
# From boostrap_admin_project.sh
# - Obtain the service account key
# - Create backend.tf
```