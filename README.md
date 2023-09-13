# Azure DNS Private Resolver Terraform module

Terraform module which creates Azure DNS Private Resolver resources on Azure.

These types of resources are supported:

* [Azure DNS Private Resolver](https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview)
* [Azure DNS Private Resolver endpoints and rulesets](https://learn.microsoft.com/en-us/azure/dns/private-resolver-endpoints-rulesets)

## Terraform versions

Terraform 1.5.6 and newer.

## Usage

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

More samples in examples folder