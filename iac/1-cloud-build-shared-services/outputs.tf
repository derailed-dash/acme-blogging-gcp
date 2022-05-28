output "cb_project_id" {
  value = module.cloudbuild_bootstrap.cloudbuild_project_id
}

output "cb_sa" {
  value = "${data.google_project.cloudbuild.number}@cloudbuild.gserviceaccount.com"
}

output "gcr_bucket_id" {
  value = google_container_registry.registry.id
}

output "gcr_url" {
  value = data.google_container_registry_repository.gcr_repo.repository_url
}