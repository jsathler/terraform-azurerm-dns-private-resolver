locals {
  tags = merge(var.tags, { ManagedByTerraform = "True" })
}

resource "azurerm_private_dns_resolver" "default" {
  name                = "${var.name}-dnspr"
  location            = var.location
  resource_group_name = var.resource_group_name
  virtual_network_id  = var.vnet_id
  tags                = local.tags
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "default" {
  for_each = { for key, value in var.inbound_endpoints : key => value }

  name                    = "${each.key}-in"
  location                = var.location
  private_dns_resolver_id = azurerm_private_dns_resolver.default.id
  tags                    = local.tags

  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = each.value
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "default" {
  for_each = { for key, value in var.outbound_endpoints : key => value }

  name                    = "${each.key}-out"
  location                = var.location
  private_dns_resolver_id = azurerm_private_dns_resolver.default.id
  subnet_id               = each.value
  tags                    = local.tags
}

resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "default" {
  for_each = { for key, value in var.forwarding_rulesets : key => value }

  name                = "${each.key}-dnsfwrs"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags

  private_dns_resolver_outbound_endpoint_ids = [for endpoint in each.value.outbound_endpoints : azurerm_private_dns_resolver_outbound_endpoint.default[endpoint].id]
}

locals {
  network_links = flatten([
    for key_rule, value_rule in var.forwarding_rulesets : [
      for key_vnet, value_vnet in value_rule.vnet_links : {
        name         = key_vnet
        vnet_id      = value_vnet
        ruleset_name = key_rule
      }
    ]
  ])
}

resource "azurerm_private_dns_resolver_virtual_network_link" "default" {
  for_each                  = { for key, value in local.network_links : value.name => value }
  name                      = "${each.key}-dnsfwrsvnetl"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.default[each.value.ruleset_name].id
  virtual_network_id        = each.value.vnet_id
}

locals {
  rules = flatten([
    for key_ruleset, value_ruleset in var.forwarding_rulesets : [
      for key_rule, value_rule in value_ruleset.rules : {
        ruleset_name       = key_ruleset
        name               = key_rule
        domain_name        = value_rule.domain_name
        target_dns_servers = value_rule.target_dns_servers
        enabled            = value_rule.enabled
      }
    ]
  ])
}

resource "azurerm_private_dns_resolver_forwarding_rule" "default" {
  for_each                  = { for key, value in local.rules : value.name => value }
  name                      = "${each.key}-dnsfwr"
  dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.default[each.value.ruleset_name].id
  domain_name               = each.value.domain_name
  enabled                   = each.value.enabled

  dynamic "target_dns_servers" {
    for_each = each.value.target_dns_servers
    content {
      ip_address = target_dns_servers.value
      port       = 53
    }
  }
}
