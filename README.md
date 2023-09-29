<!-- BEGIN_TF_DOCS -->
# Azure DNS Private Resolver Terraform module

Terraform module which creates Azure DNS Private Resolver resources on Azure.

Supported Azure services:

* [Azure DNS Private Resolver](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview)
* [Azure DNS Private Resolver endpoints and rulesets](https://learn.microsoft.com/en-us/azure/dns/private-resolver-endpoints-rulesets)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.70.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_resolver.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver) | resource |
| [azurerm_private_dns_resolver_dns_forwarding_ruleset.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_dns_forwarding_ruleset) | resource |
| [azurerm_private_dns_resolver_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_forwarding_rule) | resource |
| [azurerm_private_dns_resolver_inbound_endpoint.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_inbound_endpoint) | resource |
| [azurerm_private_dns_resolver_outbound_endpoint.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_outbound_endpoint) | resource |
| [azurerm_private_dns_resolver_virtual_network_link.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_resolver_virtual_network_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_forwarding_rulesets"></a> [forwarding\_rulesets](#input\_forwarding\_rulesets) | A MAP of forwarding rulesets to be created. The key is the ruleset name and the value are the properties<br>  - outbound\_endpoints:   (required) The outbound endpoint names to be used by this ruleset. It is the same name used in outbound\_endpoints variable<br>  - vnet\_links:           (optional) A MAP of vnet ids to link this ruleset<br>  - rules:                (optional) A block as defined bellow. A MAP of rules<br>    - domain\_name:        (required) Specifies the domain name for the Private DNS Resolver Forwarding Rule<br>    - target\_dns\_servers: (required) A list of target DNS servers IP<br>    - enabled:            (optional) Specifies the state of the Private DNS Resolver Forwarding Rule. Defaults to 'true' | <pre>map(object({<br>    outbound_endpoints = list(string)<br>    vnet_links         = optional(map(string), null)<br>    rules = optional(map(object({<br>      domain_name        = string<br>      target_dns_servers = list(string)<br>      enabled            = optional(bool, true)<br>    })), null)<br>  }))</pre> | `null` | no |
| <a name="input_inbound_endpoints"></a> [inbound\_endpoints](#input\_inbound\_endpoints) | A MAP of inbound endpoints to be created. The key is the inbound endpoint name and the value is the subnet ID. This parameter is optional | `map(string)` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The region where the VM will be created. This parameter is required | `string` | `"northeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | Virtual network name. This parameter is required | `string` | n/a | yes |
| <a name="input_outbound_endpoints"></a> [outbound\_endpoints](#input\_outbound\_endpoints) | A MAP of outbound endpoints to be created. The key is the outbound endpoint name and the value is the subnet ID. This parameter is optional | `map(string)` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the resources will be created. This parameter is required | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources. | `map(string)` | `null` | no |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | The ID of the Virtual Network that is linked to the Private DNS Resolver. This parameter is required | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_inbound_endpoint_ids"></a> [inbound\_endpoint\_ids](#output\_inbound\_endpoint\_ids) | Private DNS Resolver inbound endpoint IDs |
| <a name="output_inbound_endpoint_ips"></a> [inbound\_endpoint\_ips](#output\_inbound\_endpoint\_ips) | Private DNS Resolver inbound endpoint IP addresses |
| <a name="output_outbound_endpoint_ids"></a> [outbound\_endpoint\_ids](#output\_outbound\_endpoint\_ids) | Private DNS Resolver outbound endpoint IDs |
| <a name="output_resolver_id"></a> [resolver\_id](#output\_resolver\_id) | Private DNS Resolver ID |
| <a name="output_resolver_name"></a> [resolver\_name](#output\_resolver\_name) | Private DNS Resolver name |
| <a name="output_rule_ids"></a> [rule\_ids](#output\_rule\_ids) | Private DNS Resolver rule IDs |
| <a name="output_ruleset_ids"></a> [ruleset\_ids](#output\_ruleset\_ids) | Private DNS Resolver rule set IDs |

## Examples
```hcl
module "private-resolver" {
  source              = "jsathler/dns-private-resolver/azurerm"
  name                = "private-resolver"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  vnet_id             = module.hub-vnet.vnet_id

  inbound_endpoints = {
    default = module.hub-vnet.subnet_ids.resolver-in-snet
  }

  outbound_endpoints = {
    default = module.hub-vnet.subnet_ids.resolver-out-snet
  }

  forwarding_rulesets = {
    hub = {
      outbound_endpoints = ["default"]
      vnet_links = {
        hub-vnet = module.hub-vnet.vnet_id
        prd-vnet = module.spoke-vnet.vnet_id
      }
      rules = {
        "example-local" = {
          domain_name        = "example.local."
          target_dns_servers = ["10.1.1.1", "10.1.1.2"]
        }
        "example-net" = {
          domain_name        = "example.net."
          target_dns_servers = ["192.168.1.1", "192.168.1.2"]
        }
      }
    }
  }
}
```
More examples in ./examples folder
<!-- END_TF_DOCS -->