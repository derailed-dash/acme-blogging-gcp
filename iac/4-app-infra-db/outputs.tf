output "secrets" {
  value = module.secret-manager.secrets
}

output "secret_ids" {
  value = module.secret-manager.ids
}