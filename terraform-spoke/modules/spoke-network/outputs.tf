output "spoke_vnet_id" {
  value       = azurerm_virtual_network.spoke.id
  description = "Spoke VNet의 리소스 ID"
}

output "app_subnet_id" {
  value       = azurerm_subnet.app_subnet.id
  description = "애플리케이션 서브넷의 리소스 ID"
}

output "db_subnet_id" {
  value       = azurerm_subnet.db_subnet.id
  description = "데이터베이스 서브넷의 리소스 ID"
}

output "spoke_rg_name" {
  value       = azurerm_resource_group.spoke_rg.name
  description = "Spoke 리소스 그룹 이름"
}
