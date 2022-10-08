<!-- BEGIN_TF_DOCS -->
# SAN Connectivity Policy Example

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

To run this example you need to execute:

```bash
terraform init
terraform plan -out="main.plan"
terraform apply "main.plan"
```

Note that this example will create resources. Resources can be destroyed with `terraform destroy`.
<!-- END_TF_DOCS -->