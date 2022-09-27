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
  # Loop to Split vHBAs defined as a Pair
  vhbas = flatten([
    for v in var.vhbas : [
      for s in range(length(v.names)) : {
        fc_zone_policies             = v.fc_zone_policies
        fibre_channel_adapter_policy = v.fibre_channel_adapter_policy
        fibre_channel_network_policy = v.fibre_channel_network_policy
        fibre_channel_qos_policy     = v.fibre_channel_qos_policy
        name                         = element(v.names, s)
        persistent_lun_bindings      = v.persistent_lun_bindings
        placement_pci_link           = v.placement_pci_link
        placement_pci_order          = element(v.placement_pci_order, s)
        placement_slot_id            = v.placement_slot_id
        placement_switch_id = length(compact(
          [v.placement_switch_id])
        ) > 0 ? v.placement_switch_id : index(v.names, element([v.names], s)) == 0 ? "A" : "B"
        placement_uplink_port = v.placement_uplink_port
        vhba_type             = v.vhba_type
        wwpn_allocation_type  = v.wwpn_allocation_type
        wwpn_pool             = length(v.wwpn_pool) > 0 ? element(v.wwpn_pool, s) : ""
        wwpn_static_address   = length(v.wwpn_static_address) > 0 ? element(v.wwpn_static_address, s) : ""
      }
    ]
  ])

  fibre_channel_adapter = toset(compact([for v in local.vhbas : v.fibre_channel_adapter_policy]))
  fibre_channel_network = toset(compact([for v in local.vhbas : v.fibre_channel_network_policy]))
  fibre_channel_qos     = toset(compact([for v in local.vhbas : v.fibre_channel_qos_policy]))
  fc_zone_policies      = toset(compact(flatten([for v in local.vhbas : v.fc_zone_policies])))
  wwpn_pools            = toset(compact([for v in local.vhbas : v.wwpn_pool]))
}

data "intersight_fabric_fc_zone_policy" "fc_zone" {
  for_each = {
    for v in local.fc_zone_policies : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

data "intersight_fcpool_pool" "wwnn" {
  for_each = {
    for v in compact([var.wwnn_pool]) : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

data "intersight_fcpool_pool" "wwpn" {
  for_each = {
    for v in local.wwpn_pools : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

data "intersight_vnic_fc_adapter_policy" "fibre_channel_adapter" {
  for_each = {
    for v in local.fibre_channel_adapter : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

data "intersight_vnic_fc_network_policy" "fibre_channel_network" {
  for_each = {
    for v in local.fibre_channel_network : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
}

data "intersight_vnic_fc_qos_policy" "fibre_channel_qos" {
  for_each = {
    for v in local.fibre_channel_qos : v => v if length(
      regexall("[[:xdigit:]]{24}", v)
    ) == 0
  }
  name = each.value
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
      moid = length(
        regexall("[[:xdigit:]]{24}", wwnn_pool.value)
      ) > 0 ? wwnn_pool.value : data.intersight_fcpool_pool.wwnn[wwnn_pool.value].results[0].moid
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
  for_each            = { for v in local.vhbas : v.name => v }
  name                = each.key
  order               = each.value.placement_pci_order
  persistent_bindings = each.value.persistent_lun_bindings
  static_wwpn_address = each.value.wwpn_allocation_type == "STATIC" ? each.value.wwpn_static_address : ""
  type                = each.value.vhba_type
  wwpn_address_type   = each.value.wwpn_allocation_type
  fc_adapter_policy {
    moid = length(
      regexall("[[:xdigit:]]{24}", each.value.fibre_channel_adapter_policy)
      ) > 0 ? each.value.fibre_channel_adapter_policy : data.intersight_vnic_fc_adapter_policy.fibre_channel_adapter[
      each.value.fibre_channel_adapter_policy
    ].results[0].moid
  }
  fc_network_policy {
    moid = length(
      regexall("[[:xdigit:]]{24}", each.value.fibre_channel_network_policy)
      ) > 0 ? each.value.fibre_channel_network_policy : data.intersight_vnic_fc_network_policy.fibre_channel_network[
      each.value.fibre_channel_network_policy
    ].results[0].moid
  }
  fc_qos_policy {
    moid = length(
      regexall("[[:xdigit:]]{24}", each.value.fibre_channel_qos_policy)
      ) > 0 ? each.value.fibre_channel_qos_policy : data.intersight_vnic_fc_qos_policy.fibre_channel_qos[
      each.value.fibre_channel_qos_policy
    ].results[0].moid
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
      moid = length(
        regexall("[[:xdigit:]]{24}", fc_zone_policies.value)
        ) > 0 ? fc_zone_policies.value : data.intersight_fabric_fc_zone_policy.fc_zone_policies[
        fc_zone_policies.value
      ].moid
    }
  }
  dynamic "wwpn_pool" {
    for_each = { for v in compact([each.value.wwpn_pool]) : v => v }
    content {
      moid = length(
        regexall("[[:xdigit:]]{24}", wwpn_pool.value)
      ) > 0 ? wwpn_pool.value : data.intersight_fcpool_pool.wwpn[wwpn_pool.value].results[0].moid
    }
  }
}
