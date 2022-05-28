prefix = "cb"

apis = [
  "cloudresourcemanager.googleapis.com",
  "compute.googleapis.com",
  "iam.googleapis.com",
  "admin.googleapis.com",
  "cloudbilling.googleapis.com",
  "serviceusage.googleapis.com",
  "monitoring.googleapis.com",
  "logging.googleapis.com",
  "cloudbuild.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "run.googleapis.com",
  "containerregistry.googleapis.com",
  "container.googleapis.com",
  "servicenetworking.googleapis.com",
  "storage-api.googleapis.com",
  "appengine.googleapis.com",
  "cloudfunctions.googleapis.com",
  "sqladmin.googleapis.com",
  "iap.googleapis.com",
  "oslogin.googleapis.com",
  "iamcredentials.googleapis.com",
  "bigquery.googleapis.com",  
  "secretmanager.googleapis.com",
  "billingbudgets.googleapis.com",
  "cloudkms.googleapis.com"
]

org_admins = "gcp-organization-admins@just2good.co.uk"

# We'll only use this list if we run terraform-google-modules/bootstrap/google
# But currently, we're only running terraform-google-modules/bootstrap/google//modules/cloudbuild
# org_admin_permissions = [
#   "roles/iam.organizationRoleAdmin",
#   "roles/billing.user",
#   "roles/compute.networkAdmin",  
#   "roles/compute.osAdminLogin",
#   "roles/compute.xpnAdmin",  
#   "roles/cloudsupport.admin",
#   "roles/compute.osLogin",
#   "roles/compute.osLoginExternalUser",
#   "roles/iam.serviceAccountTokenCreator",
#   "roles/iam.securityAdmin",
#   "roles/iam.serviceAccountAdmin",
#   "roles/orgpolicy.policyAdmin",
#   "roles/resourcemanager.folderAdmin",
#   "roles/resourcemanager.organizationAdmin",
#   "roles/resourcemanager.organizationViewer",
#   "roles/resourcemanager.projectCreator",
#   "roles/resourcemanager.projectDeleter",
#   "roles/securitycenter.admin",
#   "roles/serviceusage.serviceUsageAdmin",
#   "roles/securitycenter.notificationConfigEditor",
#   "roles/resourcemanager.organizationViewer"
# ]
