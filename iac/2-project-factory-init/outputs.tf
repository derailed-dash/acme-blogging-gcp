output "project_info" {
  value = google_project.project
}

output "project_suffix" {
  value = random_id.project_suffix.hex
}

output "buckets" {
  value = module.bucket
}