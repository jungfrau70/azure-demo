output "vnet_id" {
  value       = azurerm_virtual_network.hub.id
  description = "Hub VNet ID"
}

output "vnet_name" {
  value       = azurerm_virtual_network.hub.name
  description = "Hub VNet 이름"
}

output "fw_subnet_id" {
  description = "Firewall 서브넷 ID"
  value       = azurerm_subnet.fw_subnet.id
} 