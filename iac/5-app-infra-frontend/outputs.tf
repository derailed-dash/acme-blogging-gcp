output "websvr_lb_ip" {
  value = google_compute_global_address.lb_ext_ip.address
}

output "domains" {
  value = local.domains
}