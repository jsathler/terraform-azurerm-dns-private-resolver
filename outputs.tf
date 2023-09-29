output "resolver_name" {
  description = "Private DNS Resolver name"
  value       = azurerm_private_dns_resolver.default.name
}

output "resolver_id" {
  description = "Private DNS Resolver ID"
  value       = azurerm_private_dns_resolver.default.id
}

output "inbound_endpoint_ids" {
  description = "Private DNS Resolver inbound endpoint IDs"
  value       = { for key, value in azurerm_private_dns_resolver_inbound_endpoint.default : value.name => value.id }
}

output "inbound_endpoint_ips" {
  description = "Private DNS Resolver inbound endpoint IP addresses"
  value       = { for key, value in azurerm_private_dns_resolver_inbound_endpoint.default : value.name => value.ip_configurations[0].private_ip_address }
}

output "outbound_endpoint_ids" {
  description = "Private DNS Resolver outbound endpoint IDs"
  value       = { for key, value in azurerm_private_dns_resolver_outbound_endpoint.default : value.name => value.id }
}

output "ruleset_ids" {
  description = "Private DNS Resolver rule set IDs"
  value       = { for key, value in azurerm_private_dns_resolver_dns_forwarding_ruleset.default : value.name => value.id }
}

output "rule_ids" {
  description = "Private DNS Resolver rule IDs"
  value       = { for key, value in azurerm_private_dns_resolver_forwarding_rule.default : value.name => value.id }
}
