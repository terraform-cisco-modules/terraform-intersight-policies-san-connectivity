module "san_connectivity" {
  source  = "terraform-cisco-modules/policies-san-connectivity/intersight"
  version = ">= 1.0.1"

  description  = "default SAN Connectivity Policy."
  name         = "default"
  organization = "default"
  vhbas = [{
    fc_zone_policies             = []
    fibre_channel_adapter_policy = "default"
    fibre_channel_network_policy = "default"
    fibre_channel_qos_policy     = "default"
    name                         = "vHBA-A"
    persistent_lun_bindings      = false
    placement_pci_link           = 0
    placement_pci_order          = 0
    placement_slot_id            = "MLOM"
    placement_switch_id          = "A"
    placement_uplink_port        = 0
    vhba_type                    = "fc-initiator"
    wwpn_allocation_type         = "POOL"
    wwpn_pool                    = "default"
    wwpn_static_address          = ""
  }]
  wwnn_pool = "default"
}
