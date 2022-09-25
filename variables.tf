#____________________________________________________________
#
# Ethernet SAN Connectivity Policy Variables Section.
#____________________________________________________________

variable "description" {
  default     = ""
  description = "Description for the Policy."
  type        = string
}

variable "name" {
  default     = "san_connectivity"
  description = "Name for the Policy."
  type        = string
}

variable "organization" {
  default     = "default"
  description = "Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/."
  type        = string
}

variable "profiles" {
  default     = []
  description = <<-EOT
    List of Profiles to Assign to the Policy.
    * name - Name of the Profile to Assign.
    * object_type - Object Type to Assign in the Profile Configuration.
      - server.Profile - For UCS Server Profiles.
      - server.ProfileTemplate - For UCS Server Profile Templates.
  EOT
  type = list(object(
    {
      name        = string
      object_type = optional(string, "server.Profile")
    }
  ))
}

variable "static_wwnn_address" {
  default     = ""
  description = "The WWNN address for the server node must be in hexadecimal format xx:xx:xx:xx:xx:xx:xx:xx.  Allowed ranges are 20:00:00:00:00:00:00:00 to 20:FF:FF:FF:FF:FF:FF:FF or from 50:00:00:00:00:00:00:00 to 5F:FF:FF:FF:FF:FF:FF:FF.  To ensure uniqueness of WWN's in the SAN fabric, you are strongly encouraged to use the WWN prefix - 20:00:00:25:B5:xx:xx:xx."
  type        = string
}

variable "tags" {
  default     = []
  description = "List of Tag Attributes to Assign to the Policy."
  type        = list(map(string))
}

variable "target_platform" {
  default     = "FIAttached"
  description = <<-EOT
  The platform for which the server profile is applicable. It can either be:
  * Standalone - a server that is operating independently
  * FIAttached - A Server attached to a Intersight Managed Domain.
  EOT
  type        = string
}

variable "vhba_placement_mode" {
  default     = "custom"
  description = <<-EOT
  The mode used for placement of vNICs on network adapters. It can either be Auto or Custom.
  * auto - The placement of the vNICs / vHBAs on network adapters is automatically determined by the system.
  * custom - The placement of the vNICs / vHBAs on network adapters is manually chosen by the user.
  EOT
  type        = string
}

variable "vhbas" {
  default = []
  /*
    {
      fc_zone_policies             = []
      fibre_channel_adapter_policy = "**REQUIRED**"
      fibre_channel_network_policy = "**REQUIRED**"
      fibre_channel_qos_policy     = "**REQUIRED**"
      name                         = "vhba"
      persistent_lun_bindings      = false
      placement_pci_link           = 0
      placement_pci_order          = 0
      placement_slot_id            = "MLOM"
      placement_switch_id          = "None"
      placement_uplink_port        = 0
      vhba_type                    = "fc-initiator"
      wwpn_allocation_type         = "POOL"
      wwpn_pool                    = ""
      wwpn_static_address          = ""
    }
    */
  description = <<-EOT
    List of vHBAs to add to the SAN Connectivity Policy.
    * fc_zone_policies - List of FC Zone Policy Names to attach to the vHBA.
    * fibre_channel_adapter_policy - The Name of the Fibre Channel Adapter Policy to Assign to the vHBA.
    * fibre_channel_network_policy - The Name of the Fibre Channel Network Policy to Assign to the vHBA.
    * fibre_channel_qos_policy - The Name of the Fibre Channel QoS Policy to Assign to the vHBA.
    * name - Name of the virtual fibre channel interface.
    * persistent_lun_bindings: (default is false) - Enables retention of LUN ID associations in memory until they are manually cleared.
    * placement_pci_link: (default is 0) - The PCI Link used as transport for the virtual interface. All VIC adapters have a single PCI link except VIC 1385 which has two.
    * placement_pci_order: (default is 0) - The order in which the virtual interface is brought up. The order assigned to an interface should be unique for all the Ethernet and Fibre-Channel interfaces on each PCI link on a VIC adapter. The maximum value of PCI order is limited by the number of virtual interfaces (Ethernet and Fibre-Channel) on each PCI link on a VIC adapter. All VIC adapters have a single PCI link except VIC 1385 which has two.
    * placement_slot_id: (default is MLOM) - PCIe Slot where the VIC adapter is installed. Supported values are (1-15) and MLOM.
    * placement_switch_id - The fabric port to which the vNICs will be associated.
      1. A - Fabric A of the FI cluster.
      2. B - Fabric B of the FI cluster.
      3. None (Default) - Fabric Id is not set to either A or B for the standalone case where the server is not connected to Fabric Interconnects. The value 'None' should be used.
    * placement_uplink_port - Default is 0.  Adapter port on which the virtual interface will be created.  This attribute is for Standalone Servers Only.
    * vhba_type - VHBA Type configuration for SAN Connectivity Policy. This configuration is supported only on Cisco VIC 14XX series and higher series of adapters.
      1. fc-initiator (Default) - The default value set for vHBA Type Configuration. Fc-initiator specifies vHBA as a consumer of storage. Enables SCSI commands to transfer data and status information between host and target storage systems.
      2. fc-nvme-initiator - Fc-nvme-initiator specifies vHBA as a consumer of storage. Enables NVMe-based message commands to transfer data and status information between host and target storage systems.
      3. fc-nvme-target - Fc-nvme-target specifies vHBA as a provider of storage volumes to initiators. Enables NVMe-based message commands to transfer data and status information between host and target storage systems. Currently tech-preview, only enabled with an asynchronous driver.
      4. fc-target - Fc-target specifies vHBA as a provider of storage volumes to initiators. Enables SCSI commands to transfer data and status information between host and target storage systems. fc-target is enabled only with an asynchronous driver.
    * wwpn_allocation_type -  Type of allocation selected to assign a WWPN address to the vhba.
      1. POOL - The user selects a pool from which the mac/wwn address will be leased for the Virtual Interface.
      2. STATIC - The user assigns a static mac/wwn address for the Virtual Interface.
    * wwpn_static_address -  The WWPN address must be in hexadecimal format xx:xx:xx:xx:xx:xx:xx:xx.  Allowed ranges are 20:00:00:00:00:00:00:00 to 20:FF:FF:FF:FF:FF:FF:FF or from 50:00:00:00:00:00:00:00 to 5F:FF:FF:FF:FF:FF:FF:FF.  To ensure uniqueness of WWN's in the SAN fabric, you are strongly encouraged to use the WWN prefix - 20:00:00:25:B5:xx:xx:xx.
  EOT
  type = list(object(
    {
      fc_zone_policies             = optional(list(string))
      fibre_channel_adapter_policy = string
      fibre_channel_network_policy = string
      fibre_channel_qos_policy     = string
      name                         = string
      persistent_lun_bindings      = optional(bool, false)
      placement_pci_link           = optional(number, 0)
      placement_pci_order          = optional(number, 0)
      placement_slot_id            = optional(string, "MLOM")
      placement_switch_id          = optional(string)
      placement_uplink_port        = optional(number)
      vhba_type                    = optional(string)
      wwpn_allocation_type         = optional(string)
      wwpn_pool                    = optional(string)
      wwpn_static_address          = optional(string)
    }
  ))
}

variable "wwnn_allocation_type" {
  default     = "POOL"
  description = <<-EOT
  Type of allocation selected to assign a WWNN address for the server node.
  * POOL - The user selects a pool from which the mac/wwn address will be leased for the Virtual Interface.
  * STATIC - The user assigns a static mac/wwn address for the Virtual Interface.
  EOT
  type        = string
}

variable "wwnn_pool" {
  default     = ""
  description = "WWNN Pool to Assign to the Policy."
  type        = string
}

variable "wwnn_static_address" {
  default     = ""
  description = "The WWNN address for the server node must be in hexadecimal format xx:xx:xx:xx:xx:xx:xx:xx.Allowed ranges are 20:00:00:00:00:00:00:00 to 20:FF:FF:FF:FF:FF:FF:FF or from 50:00:00:00:00:00:00:00 to 5F:FF:FF:FF:FF:FF:FF:FF.To ensure uniqueness of WWN's in the SAN fabric, you are strongly encouraged to use the WWN prefix - 20:00:00:25:B5:xx:xx:xx."
  type        = string
}
