resource "azurerm_private_dns_zone" "private_dns" {
  for_each = toset([
    "privatelink.azurecr.io",
    "privatelink.vaultcore.azure.net",
    "privatelink.azurewebsites.net"
  ])

  name                = each.key
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub_link" {
  for_each = azurerm_private_dns_zone.private_dns

  name                  = "hub-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = var.hub_vnet_id
} 