locals {
    tf_sa_email = "terraform@${var.admin_id}.iam.gserviceaccount.com"

    # projects/dazbo-acme-infra-admin-1/serviceAccounts/terraform@dazbo-acme-infra-admin-1.iam.gserviceaccount.com
    tf_sa_name = "projects/${var.admin_id}/serviceAccounts/terraform@${var.admin_id}.iam.gserviceaccount.com"
}