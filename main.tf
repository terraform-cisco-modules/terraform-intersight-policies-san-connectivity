#____________________________________________________________
#
# Intersight Organization Data Source
# GUI Location: Settings > Settings > Organizations > {Name}
#____________________________________________________________

data "intersight_organization_organization" "org_moid" {
  for_each = {
    for v in [var.organization] : v => v if length(
      regexall("[[:xdigit:]]{24}", var.organization)
    ) == 0
  }
  name = each.value
}

#____________________________________________________________
#
# Intersight UCS Server Profile(s) Data Source
# GUI Location: Profiles > UCS Server Profiles > {Name}
#____________________________________________________________

data "intersight_server_profile" "profiles" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.Profile" }
  name     = each.value.name
}

#__________________________________________________________________
#
# Intersight UCS Server Profile Template(s) Data Source
# GUI Location: Templates > UCS Server Profile Templates > {Name}
#__________________________________________________________________

data "intersight_server_profile_template" "templates" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.ProfileTemplate" }
  name     = each.value.name
}

locals {
  fibre_channel_adapter = toset(compact([for v in var.vhbas : v.fibre_channel_adapter_policy]))
  fibre_channel_network = toset(compact([for v in var.vhbas : v.fibre_channel_network_policy]))
  fibre_channel_qos     = toset(compact([for v in var.vhbas : v.fibre_channel_qos_policy]))
  fc_zone_policies      = toset(compact(flatten([for v in var.vhbas : v.fc_zone_policies])))
  wwpn_pools            = toset(compact([for v in var.vhbas : v.wwpn_pool]))
}

data "intersight_fabric_fc_zone_policy" "fc_zone" {
  for_each = { for v in local.fc_zone_policies : v => v }
  name     = each.value
}

data "intersight_fcpool_pool" "wwnn" {
  for_each = { for v in compact([var.wwnn_pool]) : v => v }
  name     = each.value
}

data "intersight_fcpool_pool" "wwpn" {
  for_each = { for v in local.wwpn_pools : v => v }
  name     = each.value
}

data "intersight_vnic_fc_adapter_policy" "fibre_channel_adapter" {
  for_each = { for v in local.fibre_channel_adapter : v => v }
  name     = each.value
}

data "intersight_vnic_fc_network_policy" "fibre_channel_network" {
  for_each = { for v in local.fibre_channel_network : v => v }
  name     = each.value
}

data "intersight_vnic_fc_qos_policy" "fibre_channel_qos" {
  for_each = { for v in local.fibre_channel_qos : v => v }
  name     = each.value
}


#__________________________________________________________________
#
# Intersight SAN Connectivity Policy
# GUI Location: Policies > Create Policy > SAN Connectivity
#__________________________________________________________________

resource "intersight_vnic_san_connectivity_policy" "san_connectivity" {
  depends_on = [
    data.intersight_server_profile.profiles,
    data.intersight_server_profile_template.templates,
    data.intersight_organization_organization.org_moid
  ]
  description         = var.description != "" ? var.description : "${var.name} SAN Connectivity Policy."
  name                = var.name
  placement_mode      = var.vhba_placement_mode
  static_wwnn_address = var.wwnn_static_address
  target_platform     = var.target_platform
  wwnn_address_type   = var.wwnn_allocation_type
  organization {
    moid = length(
      regexall("[[:xdigit:]]{24}", var.organization)
      ) > 0 ? var.organization : data.intersight_organization_organization.org_moid[
      var.organization].results[0
    ].moid
    object_type = "organization.Organization"
  }
  dynamic "profiles" {
    for_each = { for v in var.profiles : v.name => v }
    content {
      moid = length(regexall("server.ProfileTemplate", profiles.value.object_type)
        ) > 0 ? data.intersight_server_profile_template.templates[profiles.value.name].results[0
      ].moid : data.intersight_server_profile.profiles[profiles.value.name].results[0].moid
      object_type = profiles.value.object_type
    }
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
  dynamic "wwnn_pool" {
    for_each = { for v in compact([var.wwnn_pool]) : v => v }
    content {
      moid = data.intersight_fcpool_pool.wwnn[wwnn_pool.value].results[0].moid
    }
  }
}


#____________________________________________________________
#
# Intersight Fibre Channel (vHBA) Policy
# GUI Location: Policies > Create Policy
#____________________________________________________________

resource "intersight_vnic_fc_if" "vhbas" {
  depends_on = [
    data.intersight_fabric_fc_zone_policy.fc_zone,
    data.intersight_vnic_fc_adapter_policy.fibre_channel_adapter,
    data.intersight_vnic_fc_network_policy.fibre_channel_network,
    data.intersight_vnic_fc_qos_policy.fibre_channel_qos,
    intersight_vnic_san_connectivity_policy.san_connectivity
  ]
  for_each            = { for v in var.vhbas : v.name => v }
  name                = each.key
  order               = each.value.placement_pci_order
  persistent_bindings = each.value.persistent_lun_bindings
  static_wwpn_address = each.value.wwpn_allocation_type == "STATIC" ? each.value.wwpn_static_address : ""
  type                = each.value.vhba_type
  wwpn_address_type   = each.value.wwpn_allocation_type
  fc_adapter_policy {
    moid = data.intersight_vnic_fc_adapter_policy.fibre_channel_adapter[
      each.value.fibre_channel_adapter_policy
    ].moid
  }
  fc_network_policy {
    moid = data.intersight_vnic_fc_network_policy.fibre_channel_network[
      each.value.fibre_channel_network_policy
    ].moid
  }
  fc_qos_policy {
    moid = data.intersight_vnic_fc_qos_policy.fibre_channel_qos[
      each.value.fibre_channel_qos_policy
    ].moid
  }
  san_connectivity_policy {
    moid = intersight_vnic_san_connectivity_policy.san_connectivity.moid
  }
  placement {
    id        = each.value.placement_slot_id
    pci_link  = each.value.placement_pci_link
    switch_id = each.value.placement_switch_id
    uplink    = each.value.placement_uplink_port
  }
  dynamic "fc_zone_policies" {
    for_each = toset(each.value.fc_zone_policies)
    content {
      moid = data.intersight_fabric_fc_zone_policy.fc_zone_policies[fc_zone_policies.value].moid
    }
  }
  dynamic "wwpn_pool" {
    for_each = { for v in compact([each.value.wwpn_pool]) : v => v }
    content {
      moid = data.intersight_fcpool_pool.wwpn[wwpn_pool.value].results[0].moid
    }
  }
}
