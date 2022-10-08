#____________________________________________________________
#
# Collect the moid of the SAN Connectivity Policy
#____________________________________________________________

output "moid" {
  description = "SAN Connectivity Policy Managed Object ID (moid)."
  value       = intersight_vnic_san_connectivity_policy.san_connectivity.moid
}

output "vhbas" {
  description = "SAN Connectivity Policy vHBA(s) Moid(s)."
  value = {
    for v in sort(keys(intersight_vnic_fc_if.vhbas)
    ) : v => intersight_vnic_fc_if.vhbas[v].moid
  }
}
