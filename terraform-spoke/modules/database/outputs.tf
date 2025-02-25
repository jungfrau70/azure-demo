output "server_name" {
  value = azurerm_postgresql_flexible_server.db.name
}

output "server_fqdn" {
  value = azurerm_postgresql_flexible_server.db.fqdn
}

output "connection_string" {
  value     = "postgresql://${azurerm_postgresql_flexible_server.db.administrator_login}@${azurerm_postgresql_flexible_server.db.name}:${azurerm_postgresql_flexible_server.db.administrator_password}@${azurerm_postgresql_flexible_server.db.fqdn}:5432/postgres"
  sensitive = true
} 