export TF_VAR_org=ds
export TF_VAR_org_id=012345678901
export TF_VAR_top_folder=123456789012
export TF_VAR_shared_folder_id=234567890123
export TF_VAR_billing_account=012345-6789AB-CDEF01
export TF_ADMIN_NAME=acme-infra-admin                 # The name of our TF Admin Project and Service Account
export TF_VAR_admin_id=${TF_ADMIN_NAME}-6821            # The ID of our TF Admin Project. Needs to be globally unique.
export TF_CREDS=~/.config/gcloud/${TF_ADMIN_NAME}.json   # svc account credentials
export CTR_CREDS=/root/.config/gcloud/${TF_ADMIN_NAME}.json  # in case we're using a Docker gcloud

# Set environment vars to be used for Google Cloud TF provider
export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_VAR_admin_id}