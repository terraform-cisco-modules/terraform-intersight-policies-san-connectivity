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
    names                        = ["vHBA-A", "vHBA-B"]
    persistent_lun_bindings      = false
    placement_pci_order          = [0, 1]
    placement_slot_id            = ["MLOM"]
    vhba_type                    = "fc-initiator"
    wwpn_allocation_type         = "POOL"
    wwpn_pools                   = ["default", "default"]
    wwpn_static_addresss         = []
  }]
  wwnn_pool = "default"
}
