###############################
# Provision compute resources #
###############################

#############################################################################
# Bastions
#
# Here we provision an infra-admin machine.  Only accessible using IAP.                    
#############################################################################

# Create as a bastion server.
# Automatically creates allow-ssh-from-iap-to-tunnel firewall rule, i.e. from 35.235.240.0/20
# Creates SA.
module "infra_vm" {
  project = var.project_id
  source = "terraform-google-modules/bastion-host/google"

  name = "infra-vm"
  network = module.vpc.network_id
  subnet  = module.vpc.subnets["${var.regions.pri}/${local.infra_subnet}"].id
  zone    = data.google_compute_zones.pri_zones.names[0]  
  machine_type = var.machine_types.small
  labels = {
    "type" = "infra"
  }

  metadata = {
    # startup-script = templatefile("${path.module}/infra-vm.tpl", {labels = local.labels})
    startup-script = file("${path.module}/infra-vm.tpl")    
  }
  members = var.iap_groups
}