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
