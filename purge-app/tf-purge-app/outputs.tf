output "posts_get_function" {
  value = google_cloudfunctions_function.posts_get_function
}

output "vpc_connector" {
  value = local.vpc_connector
}

output "db_pwd_secret_id" {
  value = local.pwd_secret_id
}

output "db_pwd_secret_ver" {
  value = local.pwd_secret_version
}

output "repo" {
  value = var.src_repo
}