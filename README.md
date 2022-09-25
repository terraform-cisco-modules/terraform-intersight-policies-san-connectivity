<!-- BEGIN_TF_DOCS -->
# Terraform Intersight Policies - SAN Connectivity
Manages Intersight SAN Connectivity Policies

Location in GUI:
`Policies` » `Create Policy` » `SAN Connectivity`

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
  secretkey = var.secretkey
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
  description = "Intersight Secret Key."
  sensitive   = true
  type        = string
}
```

## Environment Variables

### Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with value of [your-api-key]
- Add variable secretkey with value of [your-secret-file-content]

### Linux
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkey=`cat <secret-key-file-location>`
```

### Windows
```bash
$env:TF_VAR_apikey="<your-api-key>"
$env:TF_VAR_secretkey="<secret-key-file-location>""
```
<!-- END_TF_DOCS -->