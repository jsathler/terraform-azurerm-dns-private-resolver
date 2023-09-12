variable "location" {
  description = "The region where the VM will be created. This parameter is required"
  type        = string
  default     = "northeurope"
}

variable "name" {
  description = "Virtual network name. This parameter is required"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created. This parameter is required"
  type        = string
}

variable "vnet_id" {
  description = "The ID of the Virtual Network that is linked to the Private DNS Resolver. This parameter is required"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources."
  type        = map(string)
  default     = null
}

variable "inbound_endpoints" {
  description = "A MAP of inbound endpoints to be created. The key is the inbound endpoint name and the value is the subnet ID. This parameter is optional"
  type        = map(string)
  default     = null
}

variable "outbound_endpoints" {
  description = "A MAP of outbound endpoints to be created. The key is the outbound endpoint name and the value is the subnet ID. This parameter is optional"
  type        = map(string)
  default     = null
}

variable "forwarding_rulesets" {
  description = <<DESCRIPTION
  A MAP of forwarding rulesets to be created. The key is the ruleset name and the value are the properties
  - outbound_endpoints:   (required) The outbound endpoint names to be used by this ruleset. It is the same name used in outbound_endpoints variable
  - vnet_links:           (optional) A MAP of vnet ids to link this ruleset
  - rules:                (optional) A block as defined bellow. A MAP of rules
    - domain_name:        (required) Specifies the domain name for the Private DNS Resolver Forwarding Rule
    - target_dns_servers: (required) A list of target DNS servers IP
    - enabled:            (optional) Specifies the state of the Private DNS Resolver Forwarding Rule. Defaults to 'true'
  DESCRIPTION
  type = map(object({
    outbound_endpoints = list(string)
    vnet_links         = optional(map(string), null)
    rules = optional(map(object({
      domain_name        = string
      target_dns_servers = list(string)
      enabled            = optional(bool, true)
    })), null)
  }))
  default = null
}
