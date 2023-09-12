locals {
  location     = "northeurope"
  hub_subnet   = "10.0.0.0/16"
  spoke_subnet = "10.1.0.0/16"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "dnsprivateresolver-demo-rg"
  location = local.location
}

module "hub-vnet" {
  source              = "../../vnet"
  name                = "hub"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  address_space = [local.hub_subnet]

  subnets = {
    resolver-in = {
      address_prefixes   = [cidrsubnet(local.hub_subnet, 10, 0)]
      nsg_create_default = false
      service_delegation = { name = "Microsoft.Network/dnsResolvers", actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"] }
    }
    resolver-out = {
      address_prefixes   = [cidrsubnet(local.hub_subnet, 10, 1)]
      nsg_create_default = false
      service_delegation = { name = "Microsoft.Network/dnsResolvers", actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"] }
    }
  }
}

module "spoke-vnet" {
  source              = "../../vnet"
  name                = "spoke"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  address_space = [local.spoke_subnet]
}

module "private-resolver" {
  source              = "../"
  name                = "hub"
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
        "demo-local" = {
          domain_name        = "demo.local."
          target_dns_servers = ["10.1.1.1", "10.1.1.2"]
        }
        "demo-net" = {
          domain_name        = "demo.net."
          target_dns_servers = ["192.168.1.1", "192.168.1.2"]
        }
      }
    }
  }
}

output "private-resolver" {
  value = module.private-resolver
}
