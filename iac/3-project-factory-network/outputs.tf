output "vpc_network_id" {
  value = module.vpc.network_id
}

output "bastion_pri_hostname" {
  value = module.iap_bastion_pri.hostname
}

output "serverless_vpc_connector" {
  value = module.pri_serverless_connector
}