<!-- BEGIN_TF_DOCS -->
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Developed by: Cisco](https://img.shields.io/badge/Developed%20by-Cisco-blue)](https://developer.cisco.com)
[![Tests](https://github.com/terraform-cisco-modules/terraform-intersight-policies-san-connectivity/actions/workflows/terratest.yml/badge.svg)](https://github.com/terraform-cisco-modules/terraform-intersight-policies-san-connectivity/actions/workflows/terratest.yml)

# Terraform Intersight Policies - SAN Connectivity
Manages Intersight SAN Connectivity Policies

Location in GUI:
`Policies` » `Create Policy` » `SAN Connectivity`

## Easy IMM

[*Easy IMM - Comprehensive Example*](https://github.com/terraform-cisco-modules/easy-imm-comprehensive-example) - A comprehensive example for policies, pools, and profiles.

## Example

### main.tf
```hcl
module "san_connectivity" {
  source  = "terraform-cisco-modules/policies-san-connectivity/intersight"
  version = ">= 1.0.1"

  description  = "default SAN Connectivity Policy."
  name         = "default"
  organization = "default"
  vhbas = [{
    fc_zone_policies             = []
    fibre_channel_adapter_policy = "default"
    fibre_channel_network_policy = ["default", "default"]
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
```

### provider.tf
```hcl
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
  required_version = ">=1.3.0"
}

provider "intersight" {
  apikey    = var.apikey
  endpoint  = var.endpoint
  secretkey = fileexists(var.secretkeyfile) ? file(var.secretkeyfile) : var.secretkey
}
```

### variables.tf
```hcl
variable "apikey" {
  description = "Intersight API Key."
  sensitive   = true
  type        = string
}

variable "endpoint" {
  default     = "https://intersight.com"
  description = "Intersight URL."
  type        = string
}

variable "secretkey" {
  default     = ""
  description = "Intersight Secret Key Content."
  sensitive   = true
  type        = string
}

variable "secretkeyfile" {
  default     = "blah.txt"
  description = "Intersight Secret Key File Location."
  sensitive   = true
  type        = string
}
```

## Environment Variables

### Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with the value of [your-api-key]
- Add variable secretkey with the value of [your-secret-file-content]

### Linux and Windows
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkeyfile="<secret-key-file-location>"
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.32 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | 1.0.32 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey"></a> [apikey](#input\_apikey) | Intersight API Key. | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Intersight URL. | `string` | `"https://intersight.com"` | no |
| <a name="input_secretkey"></a> [secretkey](#input\_secretkey) | Intersight Secret Key. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description for the Policy. | `string` | `""` | no |
| <a name="input_moids"></a> [moids](#input\_moids) | Flag to Determine if pools and policies should be data sources or if they already defined as a moid. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Policy. | `string` | `"default"` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/. | `string` | `"default"` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Map for Moid based Policy Sources. | `any` | `{}` | no |
| <a name="input_pools"></a> [pools](#input\_pools) | Map for Moid based Pool Sources. | `any` | `{}` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | List of Profiles to Assign to the Policy.<br>* name - Name of the Profile to Assign.<br>* object\_type - Object Type to Assign in the Profile Configuration.<br>  - server.Profile - For UCS Server Profiles.<br>  - server.ProfileTemplate - For UCS Server Profile Templates. | <pre>list(object(<br>    {<br>      name        = string<br>      object_type = optional(string, "server.Profile")<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_static_wwnn_address"></a> [static\_wwnn\_address](#input\_static\_wwnn\_address) | The WWNN address for the server node must be in hexadecimal format xx:xx:xx:xx:xx:xx:xx:xx.  Allowed ranges are 20:00:00:00:00:00:00:00 to 20:FF:FF:FF:FF:FF:FF:FF or from 50:00:00:00:00:00:00:00 to 5F:FF:FF:FF:FF:FF:FF:FF.  To ensure uniqueness of WWN's in the SAN fabric, you are strongly encouraged to use the WWN prefix - 20:00:00:25:B5:xx:xx:xx. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag Attributes to Assign to the Policy. | `list(map(string))` | `[]` | no |
| <a name="input_target_platform"></a> [target\_platform](#input\_target\_platform) | The platform for which the server profile is applicable. It can either be:<br>* Standalone - a server that is operating independently<br>* FIAttached - A Server attached to a Intersight Managed Domain. | `string` | `"FIAttached"` | no |
| <a name="input_vhba_placement_mode"></a> [vhba\_placement\_mode](#input\_vhba\_placement\_mode) | The mode used for placement of vNICs on network adapters. It can either be Auto or Custom.<br>* auto - The placement of the vNICs / vHBAs on network adapters is automatically determined by the system.<br>* custom - The placement of the vNICs / vHBAs on network adapters is manually chosen by the user. | `string` | `"custom"` | no |
| <a name="input_vhbas"></a> [vhbas](#input\_vhbas) | List of vHBAs to add to the SAN Connectivity Policy.<br>* fc\_zone\_policies - List of FC Zone Policy Names to attach to the vHBA(s).<br>* fibre\_channel\_adapter\_policy: (required) - The Name of the Fibre Channel Adapter Policy to Assign to the vHBA(s).<br>* fibre\_channel\_network\_policies: (required) - The Name(s) of the Fibre Channel Network Policy to Assign to the vHBA(s).<br>* fibre\_channel\_qos\_policy: (required) - The Name of the Fibre Channel QoS Policy to Assign to the vHBA.<br>* names - Name of the vHBA(s).<br>* persistent\_lun\_bindings: (default is false) - Enables retention of LUN ID associations in memory until they are manually cleared.<br>* placement\_pci\_link: (default is [0]) - The PCI Link used as transport for the virtual interface. All VIC adapters have a single PCI link except VIC 1385 which has two.<br>* placement\_pci\_order: (default is [0, 1]) - The order in which the virtual interface is brought up. The order assigned to an interface should be unique for all the Ethernet and Fibre-Channel interfaces on each PCI link on a VIC adapter. The maximum value of PCI order is limited by the number of virtual interfaces (Ethernet and Fibre-Channel) on each PCI link on a VIC adapter. All VIC adapters have a single PCI link except VIC 1385 which has two.<br>* placement\_slot\_id: (default is [MLOM]) - PCIe Slot where the VIC adapter is installed. Supported values are (1-15) and MLOM.<br>* placement\_switch\_id - The fabric port to which the vNICs will be associated.<br>  1. A - Fabric A of the FI cluster.<br>  2. B - Fabric B of the FI cluster.<br>  3. None: (default) - Fabric Id is not set to either A or B for the standalone case where the server is not connected to Fabric Interconnects. The value 'None' should be used.<br>* placement\_uplink\_port: (default is [0]) - Adapter port on which the virtual interface will be created.  This attribute is for Standalone Servers Only.<br>* vhba\_type - VHBA Type configuration for SAN Connectivity Policy. This configuration is supported only on Cisco VIC 14XX series and higher series of adapters.<br>  1. fc-initiator: (default) - The default value set for vHBA Type Configuration. Fc-initiator specifies vHBA as a consumer of storage. Enables SCSI commands to transfer data and status information between host and target storage systems.<br>  2. fc-nvme-initiator - Fc-nvme-initiator specifies vHBA as a consumer of storage. Enables NVMe-based message commands to transfer data and status information between host and target storage systems.<br>  3. fc-nvme-target - Fc-nvme-target specifies vHBA as a provider of storage volumes to initiators. Enables NVMe-based message commands to transfer data and status information between host and target storage systems. Currently tech-preview, only enabled with an asynchronous driver.<br>  4. fc-target - Fc-target specifies vHBA as a provider of storage volumes to initiators. Enables SCSI commands to transfer data and status information between host and target storage systems. fc-target is enabled only with an asynchronous driver.<br>* wwpn\_allocation\_type -  Type of allocation selected to assign a WWPN address to the vhba.<br>  1. POOL: (default) - The user selects a pool from which the mac/wwn address will be leased for the Virtual Interface.<br>  2. STATIC - The user assigns a static mac/wwn address for the Virtual Interface.<br>* wwpn\_pools: (optional) - A List of one or two wwpn\_pools to apply to either a single vHBA or two vHBA(s).<br>* wwpn\_static\_address: (optional) -  The WWPN address must be in hexadecimal format xx:xx:xx:xx:xx:xx:xx:xx.  Allowed ranges are 20:00:00:00:00:00:00:00 to 20:FF:FF:FF:FF:FF:FF:FF or from 50:00:00:00:00:00:00:00 to 5F:FF:FF:FF:FF:FF:FF:FF.  To ensure uniqueness of WWN's in the SAN fabric, you are strongly encouraged to use the WWN prefix - 20:00:00:25:B5:xx:xx:xx. | <pre>list(object(<br>    {<br>      fc_zone_policies               = optional(list(string), [])<br>      fibre_channel_adapter_policy   = string<br>      fibre_channel_network_policies = list(string)<br>      fibre_channel_qos_policy       = string<br>      names                          = list(string)<br>      persistent_lun_bindings        = optional(bool, false)<br>      placement_pci_link             = optional(list(number), [0])<br>      placement_pci_order            = optional(list(string), [0, 1])<br>      placement_slot_id              = optional(list(string), ["MLOM"])<br>      placement_switch_id            = optional(string, "A")<br>      placement_uplink_port          = optional(list(number), [0])<br>      vhba_type                      = optional(string, "fc-initiator")<br>      wwpn_allocation_type           = optional(string, "POOL")<br>      wwpn_pools                     = optional(list(string))<br>      wwpn_static_address            = optional(list(string))<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_wwnn_allocation_type"></a> [wwnn\_allocation\_type](#input\_wwnn\_allocation\_type) | Type of allocation selected to assign a WWNN address for the server node.<br>* POOL - The user selects a pool from which the mac/wwn address will be leased for the Virtual Interface.<br>* STATIC - The user assigns a static mac/wwn address for the Virtual Interface. | `string` | `"POOL"` | no |
| <a name="input_wwnn_pool"></a> [wwnn\_pool](#input\_wwnn\_pool) | WWNN Pool to Assign to the Policy. | `string` | `""` | no |
| <a name="input_wwnn_static_address"></a> [wwnn\_static\_address](#input\_wwnn\_static\_address) | The WWNN address for the server node must be in hexadecimal format xx:xx:xx:xx:xx:xx:xx:xx.Allowed ranges are 20:00:00:00:00:00:00:00 to 20:FF:FF:FF:FF:FF:FF:FF or from 50:00:00:00:00:00:00:00 to 5F:FF:FF:FF:FF:FF:FF:FF.To ensure uniqueness of WWN's in the SAN fabric, you are strongly encouraged to use the WWN prefix - 20:00:00:25:B5:xx:xx:xx. | `string` | `""` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_moid"></a> [moid](#output\_moid) | SAN Connectivity Policy Managed Object ID (moid). |
| <a name="output_vhbas"></a> [vhbas](#output\_vhbas) | SAN Connectivity Policy vHBA(s) Moid(s). |
## Resources

| Name | Type |
|------|------|
| [intersight_vnic_fc_if.vhbas](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_fc_if) | resource |
| [intersight_vnic_san_connectivity_policy.san_connectivity](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/vnic_san_connectivity_policy) | resource |
| [intersight_fabric_fc_zone_policy.fc_zone](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/fabric_fc_zone_policy) | data source |
| [intersight_fcpool_pool.wwnn](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/fcpool_pool) | data source |
| [intersight_fcpool_pool.wwpn](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/fcpool_pool) | data source |
| [intersight_organization_organization.org_moid](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |
| [intersight_server_profile.profiles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile) | data source |
| [intersight_server_profile_template.templates](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile_template) | data source |
| [intersight_vnic_fc_adapter_policy.fibre_channel_adapter](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/vnic_fc_adapter_policy) | data source |
| [intersight_vnic_fc_network_policy.fibre_channel_network](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/vnic_fc_network_policy) | data source |
| [intersight_vnic_fc_qos_policy.fibre_channel_qos](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/vnic_fc_qos_policy) | data source |
<!-- END_TF_DOCS -->