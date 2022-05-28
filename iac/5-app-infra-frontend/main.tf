###########################################################################################
# Provision a regional MIG with HTTPS LB, a backend, and an instance template for our app #
# - With HTTPS proxy and Google-managed SSL cert                                          #                                
# - Attach autoscaler                                                                     #
# - Attach health check                                                                   #
#                                                                                         #
# The LB takes a couple of minutes to be ready.                                           #
# The cert takes considerably longer.                                                     #
###########################################################################################

data "google_compute_network" "vpc" {
  name = local.vpc_name
}

# Retrieve the secret value from Secret Manager
data "google_secret_manager_secret_version" "db_pwd" {
  secret = var.db_pwd
}

# Retrieve the compute sa private key from Secret Manager
data "google_secret_manager_secret_version" "compute_sa_key" {
  secret = var.compute_sa_key
}

resource "random_id" "certificate" {
  byte_length = 4
  prefix      = "${var.app_prefix}-cert-"

  keepers = {
    domains = join(",", local.domains)  # this value has to change if a new id should be generated
  }
}

# Create SSL cert for our domain / subdomains
resource "google_compute_managed_ssl_certificate" "cert" {
  name = random_id.certificate.hex

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = local.domains 
  }
}

# reserve IP address - we need to our domain to this address with our registrar
resource "google_compute_global_address" "lb_ext_ip" {
  name = "lb-ext-ip"
}

# # forwarding rule - HTTP only
# resource "google_compute_global_forwarding_rule" "http_fwd_rule" {
#   name                  = "lb-forwarding-rule"
#   ip_protocol           = "TCP"
#   load_balancing_scheme = "EXTERNAL"
#   port_range            = "80"
#   target                = google_compute_target_http_proxy.http_proxy.id
#   ip_address            = google_compute_global_address.lb_ext_ip.id
# }

# forwarding rule - HTTPS only
resource "google_compute_global_forwarding_rule" "https_fwd_rule" {
  name                  = "lb-forwarding-rule"
  ip_protocol           = "TCP"  
  load_balancing_scheme = "EXTERNAL"  
  port_range            = "443"
  target                = google_compute_target_https_proxy.https_proxy.id
  ip_address            = google_compute_global_address.lb_ext_ip.id
}

# HTTPS proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "lb-target-http-proxy"
  url_map          = google_compute_url_map.lb_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.cert.id]
}

# # HTTP proxy
# resource "google_compute_target_http_proxy" "http_proxy" {
#   name     = "lb-target-http-proxy"
#   url_map  = google_compute_url_map.lb_url_map.id
# }

# url map
resource "google_compute_url_map" "lb_url_map" {
  name            = "lb-${var.app_prefix}"
  default_service = google_compute_backend_service.backend_svc.id

  # host_rule {
  #   hosts        = [local.domains]
  #   path_matcher = "allpaths"
  # }

  # path_matcher {
  #   name            = "allpaths"
  #   default_service = google_compute_backend_service.backend_svc.id

  #   path_rule {
  #     paths   = ["/*"]
  #     service = google_compute_backend_service.backend_svc.id
  #   }
  # }  
}

# backend service
resource "google_compute_backend_service" "backend_svc" {
  name                     = "lb-backend-service"
  protocol                 = "HTTP"
  port_name                = "http"   # needs to match MIG named port
  load_balancing_scheme    = "EXTERNAL"
  timeout_sec              = 10
  enable_cdn               = false  # turned off, as CDN was caching the Ghost pages. Posts not showing.
  health_checks            = [google_compute_http_health_check.http-hc.id]
  backend {
    group           = google_compute_region_instance_group_manager.mig.instance_group
    balancing_mode  = "UTILIZATION" # Scale based on average backend utilisaton of the instances in the group
    capacity_scaler = 1.0
  }
}

# instance template
resource "google_compute_instance_template" "ghost_template" {
  name_prefix  = "${var.app_prefix}-svr-"  # Let TF auto-generate a name with this prefix
  machine_type = var.machine_type[terraform.workspace]

  tags         = local.tags
  labels       = local.labels

  network_interface {
    # subnetwork = "${var.regions.pri}/${local.subnets.pri_private}"
    subnetwork = local.subnets.pri_private
    stack_type         = "IPV4_ONLY"
    
    # Enable if we need to access directly, e.g. for debugging
    # access_config {
    #   # we don't need ext IP as we're using Cloud Router for outbound
    # }
  }

  disk {
    source_image = var.machine_images.ubuntu_img
    auto_delete  = true
    boot         = true
  }

  # install ghost
  metadata = {
    startup-script = templatefile("${path.module}/template/${var.app_prefix}-ctr.tpl", 
                                  { 
                                    labels = local.labels,
                                    domain = "${terraform.workspace}.${var.domain}"
                                    protocol = "https"
                                    cloud-sql-proxy-img = var.cloud_sql_proxy_img,
                                    ghost-img = var.ghost_img,
                                    db_conn_name = var.db_conn_name, 
                                    db_pwd = data.google_secret_manager_secret_version.db_pwd.secret_data 
                                    compute_sa_key = data.google_secret_manager_secret_version.compute_sa_key.secret_data
                                  }
    )
  }
  lifecycle {
    create_before_destroy = true
  }

  service_account {
    # Todo: replace with dedicated SA
    # Use default CE SA for now. Includes roles/editor which includes cloudsql.instances.get
    # email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }  
}

# http health check
resource "google_compute_http_health_check" "http-hc" {
  name               = "${var.app_prefix}-http-health-check"
  request_path       = "/"
  check_interval_sec = 10
  timeout_sec        = 1
}

# MIG manager. Creates and manages instances from a common instance template
# Supports canary releases by updating instance template
resource "google_compute_region_instance_group_manager" "mig" {
  name     = "${var.app_prefix}-mig-1"
  base_instance_name = "${var.app_prefix}-svr"  
  region   = var.regions.pri
  named_port {
    name = "http"
    port = 80 # the port that the instances are listening on
  }
  version { # point to an actual instance template
    instance_template = google_compute_instance_template.ghost_template.id
  }
  
  # Don't set target size, since we're attaching to an autoscaler.
  # This conflicts; stops autoscaler working
  # target_size = var.mig_instances[terraform.workspace]
  
  auto_healing_policies {
    # health_check      = google_compute_health_check.http-hc.id
    health_check      = google_compute_http_health_check.http-hc.id
    initial_delay_sec = 180
  }

  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 3
    max_unavailable_fixed        = 0
    replacement_method           = "SUBSTITUTE"
  }
}

# Create an autoscaling policy
resource "google_compute_region_autoscaler" "scaler" {
  name   = "${var.regions.pri}-autoscaler"
  region = var.regions.pri

  # The MIG that this autoscaling policy will autoscale
  target = google_compute_region_instance_group_manager.mig.id

  autoscaling_policy {  # default mode allows scale out and in
    min_replicas    = 1 # TODO: Set back to 2 when we want this running
    max_replicas    = 5
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}

resource "google_compute_firewall" "lb-to-instances" {
  name    = "${google_compute_region_instance_group_manager.mig.name}-firewall-lb-to-instances"
  project = var.project_id
  network = var.vpc_id
  allow {
    ports    = ["80", "443"]
    protocol = "tcp"
  }
  direction     = "INGRESS"

  priority      = 1000
  source_ranges = local.google_load_balancer_ip_ranges
  target_tags   = local.tags
}