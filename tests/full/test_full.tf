data "intersight_organization_organization" "org_moid" {
  name = "terratest"
}

module "wwnn_pool" {
  source           = "terraform-cisco-modules/pools-fc/intersight"
  version          = ">=1.0.5"
  assignment_order = "sequential"
  id_blocks = [
    {
      from = "20:00:00:25:B5:00:00:00"
      size = 1000
    }
  ]
  name         = var.name
  organization = "terratest"
  pool_purpose = "WWNN"
}

module "wwpn_pool" {
  source           = "terraform-cisco-modules/pools-fc/intersight"
  version          = ">=1.0.5"
  assignment_order = "sequential"
  id_blocks = [
    {
      from = "20:00:00:25:B5:10:00:00"
      size = 1000
    }
  ]
  name         = var.name
  organization = "terratest"
}

module "fibre_channel_adapter" {
  source  = "terraform/policies-fibre-channel-adapter/intersight"
  version = ">=1.0.2"

  adapter_template = "VMware"
  name             = var.name
  organization     = "terratest"
}

module "fibre_channel_network" {
  source  = "terraform/policies-fibre-channel-network/intersight"
  version = ">=1.0.2"

  for_each     = { for v in ["A", "B"] : v => v }
  name         = "${var.name}-${each.value}"
  organization = "terratest"
  vsan_id      = each.value == "A" ? 100 : 200
}

module "fibre_channel_qos" {
  source  = "terraform/policies-fibre-channel-qos/intersight"
  version = ">=1.0.2"

  adapter_template = "VMware"
  name             = var.name
  organization     = "terratest"
}

module "main" {
  source       = "../.."
  description  = "${var.name} SAN Connectivity Policy."
  moids        = true
  name         = var.name
  organization = data.intersight_organization_organization.org_moid.results[0].moid
  policies = {
    fibre_channel_adapter = {
      "${var.name}" = {
        moid = module.fibre_channel_adapter.moid
      }
    }
    fibre_channel_network = {
      "${var.name}-A" = {
        moid = module.fibre_channel_network["${var.name}-A"]
      }
    }
    fibre_channel_qos = {
      "${var.name}" = {
        moid = module.fibre_channel_qos.moid
      }
    }
  }
  pools = {
    wwnn = {
      "${var.name}" = {
        moid = module.wwnn_pool.moid
      }
    }
    wwpn = {
      "${var.name}" = {
        moid = module.wwpn_pool.moid
      }
    }
  }
  vhbas = [{
    fibre_channel_zone_policies    = []
    fibre_channel_adapter_policy   = var.name
    fibre_channel_network_policies = ["${var.name}-A", "${var.name}-B"]
    fibre_channel_qos_policy       = var.name
    names                          = ["vHBA-A", "vHBA-B"]
    persistent_lun_bindings        = false
    placement_pci_order            = [0, 1]
    placement_slot_id              = ["MLOM"]
    vhba_type                      = "fc-initiator"
    wwpn_allocation_type           = "POOL"
    wwpn_pools                     = [var.name, var.name]
    wwpn_static_addresss           = []
  }]
  wwnn_pool = var.name
}

output "fibre_channel_adapter" {
  value = module.fibre_channel_adapter.moid
}

output "fibre_channel_network_control" {
  value = module.fibre_channel_network_control.moid
}

output "fibre_channel_network_group" {
  value = module.fibre_channel_network_group.moid
}

output "fibre_channel_qos" {
  value = module.fibre_channel_qos.moid
}

output "wwnn_pool" {
  value = module.wwnn_pool.moid
}

output "wwnn_pool" {
  value = module.wwnn_pool.moid
}

output "vHBA-A" {
  value = module.main.vnics["vHBA-A"]
}