locals {
  project_name = lower("prj-${var.app_prefix}-${terraform.workspace}")
  project_suffix = element(split("-", google_project.project.project_id), length(split("-", google_project.project.project_id))-1)
}