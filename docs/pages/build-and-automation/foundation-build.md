---
layout: default
title: Foundation Build - Detailed Design
---
<img src="{{'/assets/images/building-foundation.png' | relative_url }}" alt="Foundation" style="margin:15px 10px 10px 15px; float: right; width:320px" />

# {{ page.title }}

This page details the one-off steps required to build the cloud foundations.

## Sections in this Page

- [Recap](#recap)
- [Google Cloud Identity](#google-cloud-identity)
  - [Identities and Groups](#identities-and-groups)
  - [Additional Policies](#additional-policies)
- [Google Cloud Organisation Foundation](#google-cloud-organisation-foundation)
- [Bootstrap the Infra-Admin Project](#bootstrap-the-infra-admin-project)
  - [Components](#components)
  - [Step 0](#step-0)
  - [To Configure the Project Factory on Another Client](#to-configure-the-project-factory-on-another-clinet)
- [Bootstrap the Cloud Build CI/CD Project](#bootstrap-the-cloud-build-cicd-project)
  - [Step 1](#step-1)
  - [Output](#output)

## Recap

A recap of the overall foundation process:

<img src="{{'/assets/images/foundation.png' | relative_url }}" alt="Foundation" style="margin:15px 10px 10px 15px;" />

## Google Cloud Identity

Here we configure users and groups.

- Provision new **Cloud Identity** for a new organisation
  - IAM and Admin &rarr; Identity & Organization &rarr; Sign Up
  - Provide organisation details and verify domain
  - Create admin account

### Identities and Groups

- Configure **identities and groups** at [Google Admin](https://admin.google.com/){:target="_blank"}
- Add users to groups.

|Groups|Members|
|------|-------|
|gcp-billing-admins@domain|Bob Billing-Admin|
|gcp-developers@domain|Dave Dev|
|gcp-devops@domain|Dave Dev|
|gcp-network-admins@domain|
|gcp-organization-admins@domain|Dazbo Org-Admin-SA|
|gcp-project-viewers@domain|Vanessa Viewer|
|gcp-security-admins@domain|

|Name|Email|Notes|
|----|-----|-----|
|Bob Billing-Admin|bob-billing-admin@domain|Can see and manage all billing information. No access to projects or project resources.|
|Dave Dev|dave-dev@domain|Can work with instances, connect to bastion, invoke functions, etc. Can only see monitoring and billing related to specific projects. No IAM. Cannot view secrets.|
|Dazbo Org-Admin|dazbo-org-admin@domain|
|Vanessa Viewer|vanessa-viewer@domain|Read only access to resources. Can see billing and monitoring data, including monitoring dashboards.|

### Additional Policies

|Principal|Role|Resource|
|-|-|-|
|gcp-organization-admins|Editor|Non-Prod|
|gcp-organization-admins|Secret Manager Admin|Non-Prod|
|gcp-organization-admins|Cloud Run Admin|Org|
|gcp-organization-admins|Cloud Functions Admin|Org|
|gcp-organization-admins|Service Account User|Org|
|gcp-organization-admins|Folder IAM Admin|Org|
|gcp-organization-admins|Monitoring Admin|Org|
|gcp-organization-admins|Monitoring Metrics Scopes Admin|Org|
|gcp-organization-admins|Editor|Non-Prod|
|gcp-organization-admins|Compute Network Admin|Non-Prod|
|gcp-organization-admins|Compute OS Login|Non-Prod|
|gcp-organization-admins|Compute OS Login External User|Non-Prod|
|gcp-project-viewers|Viewer|Org|
|gcp-project-viewers|Organisation Viewer|Org|
|gcp-project-viewers|Monitoring Viewer|Org|
|gcp-devops|Editor|Non-Prod|

## Google Cloud Organisation Foundation

Here we configure the top-level organisation in GCP.

- Configure Organisational Foundation in the [Cloud Console](https://console.cloud.google.com){:target="_blank"}
  - **Roles** to gcp-organization-admins@domain
  - **Roles** to gcp-billing-admins@domain
  - **Billing account**
  - **Resource hierarchy** (folders and projects), as shown in the [HDL](/pages/options-and-design/hld)
  - Configure org, folder and project **access policies**
  - Set up **Cloud Monitoring** and **Cloud Logging** projects
  - Enable **Security Command Centre**
  - Configure org policy to **prevent default VPC creation**, and to **prevent external IP addresses on VMs**.

## Bootstrap the Infra-Admin Project

This process automates the one-off creation of the shared _Infra-Admin Project_, which is itself a **Project Factory**.  This is where we will persist our Terraform state and allow us to run subsequent Terraform configurations. 

The process:

- Creates the infra-admin (aka "seed") project
- Links the billing account
- Creates the service account
- Obtains service account credentials
- Binds the service account to required roles
- Enables required APIs
- Creates a Cloud Storage bucket to store Terraform state

### Components

This Project Factory has been custom-built, through a combination of bash shell and a Terraform configuration.

### Step 0

Pull the repo.  Then:

```bash
cd iac/0-infra-bootstrap

# Configure variables for this org and for unique project IDs
source ../init_vars.sh

# Now run the bootstrap
sh ./boostrap_admin_project.sh
```

### To Configure the Project Factory on Another Client

Pull the repo.  Change to the `infra` folder. Then:

```bash
. init_vars.sh

# From boostrap_admin_project.sh
# - Obtain the service account key
# - Create backend.tf
```

## Bootstrap the Cloud Build CI/CD Project

Rather than re-invent the wheel, here I'm using Terraform modules from the [Google Cloud Foundation Toolkit](https://cloud.google.com/docs/terraform/blueprints/terraform-blueprints){:target="_blank"} (CFT) to help bootstrap the Cloud Build CI/CD environment.  

Here we create a project for hosting the Cloud Build pipeline.  It adds appropriate roles, and also creates a bucket to underpin the shared Google Container Repo.

### Step 1

```bash
cd iac/1-cloud-build-shared-services
source ../init_vars.sh
gcloud config set project ${TF_VAR_admin_id}

# We need to point to a new state, but in the existing bucket
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

terraform plan -out cb-proj-plan.tfplan
terraform apply "cb-proj-plan.tfplan"
```

### Output

The output looks something like this:

```text
cb_project_id = "cb-cloudbuild-6a53"
cb_sa = "800117839038@cloudbuild.gserviceaccount.com"
gcr_bucket_id = "eu.artifacts.cb-cloudbuild-6a53.appspot.com"
gcr_url = "eu.gcr.io/cb-cloudbuild-6a53"
```

Finally, enable vulnerability scanning on the new GCR through the Console.