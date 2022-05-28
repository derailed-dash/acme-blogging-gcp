output "infra_vm_hostname" {
  value = module.infra_vm.hostname
}

output "nat" {
  value = module.cloud_router
}
