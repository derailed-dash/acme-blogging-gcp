###############################
# Provision compute resources #
###############################

##############################################################################################
# Bastions
#
# Here we provision a bastion using IAP.
# This is cool, because IAP routes internally, and so we don't even need to expose the bastion
# using an external IP address!
#
##############################################################################################

# Create first bastion server.
# Automatically creates allow-ssh-from-iap-to-tunnel firewall rule, i.e. from 35.235.240.0/20
# Creates SA.
module "iap_bastion_pri" {
  project = var.project_id
  source = "terraform-google-modules/bastion-host/google"

  name = "bastion-pri"
  network = module.vpc.network_id
  subnet  = module.vpc.subnets["${var.regions.pri}/${local.subnets.pri_public}"].id
  zone    = data.google_compute_zones.pri_zones.names[0]  
  machine_type = var.machine_types.micro
  labels = merge(local.labels, {
    "type" = "bastion"
  })
  members = var.iap_groups
  startup_script = templatefile("${path.module}/template/bastion.tpl", { labels = local.labels })
}

# Any additional bastions don't need FW created and use existing SA.
module "iap_bastion_stb" {
  project = var.project_id  
  source = "terraform-google-modules/bastion-host/google"

  name = "bastion-stb"
  network = module.vpc.network_id  
  subnet  = module.vpc.subnets["${var.regions.stb}/${local.subnets.stb_public}"].id
  zone    = data.google_compute_zones.stb_zones.names[0]  
  machine_type = var.machine_types.micro
  labels = merge(local.labels, {
    "type" = "bastion"
  })

  # Second bastion, so pass in existing service account
  service_account_email = module.iap_bastion_pri.service_account
  create_firewall_rule = false  # and we don't need to recreate FW rule
  members = var.iap_groups
  startup_script = templatefile("${path.module}/template/bastion.tpl", { labels = local.labels })  

  depends_on = [module.iap_bastion_pri]
}

# Install monitoring agent on all instances
module "agent_policy" {
  source     = "terraform-google-modules/cloud-operations/google//modules/agent-policy"

  project_id = var.project_id  
  policy_id  = "ops-agents-policy"
  agent_rules = [
    {
      type               = "ops-agent"
      version            = "current-major"
      package_state      = "installed"
      enable_autoupgrade = true
    },
  ]

  os_types = [
    {
      short_name = "debian"
    },
    {
      short_name = "ubuntu"
    },
  ]
}