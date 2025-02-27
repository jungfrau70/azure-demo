resource "azurerm_postgresql_flexible_server" "db" {
  name                = "psql-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  version            = "13"
  
  delegated_subnet_id = var.subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.db.id
  public_network_access_enabled = false
  
  administrator_login    = var.admin_username
  administrator_password = var.admin_password

  storage_mb = var.storage_mb
  sku_name   = var.sku_name
  
  zone = 1

  tags = var.tags

  timeouts {
    create = "60m"
    delete = "60m"
  }

  depends_on = [
    azurerm_private_dns_zone.db,
    azurerm_private_dns_zone_virtual_network_link.db
  ]
}

resource "azurerm_private_dns_zone" "db" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  timeouts {
    create = "30m"
    delete = "30m"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                  = "psqlfs-link"
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_subnet" "snet_db" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.subnet_prefix]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
} 