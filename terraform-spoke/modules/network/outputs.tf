output "vnet_id" {
  value       = azurerm_virtual_network.spoke.id
  description = "Spoke VNet ID"
}

output "vnet_name" {
  value       = azurerm_virtual_network.spoke.name
  description = "Spoke VNet 이름"
}

output "subnet_ids" {
  value = {
    for k, v in azurerm_subnet.subnets : k => v.id
  }
  description = "생성된 서브넷 ID 맵"
}

output "network_security_group_ids" {
  value = {
    for name, nsg in azurerm_network_security_group.nsg :
    name => nsg.id
  }
  description = "NSG ID 맵"
}

output "aks_subnet_id" {
  value       = lookup(azurerm_subnet.subnets, "aks", null) != null ? azurerm_subnet.subnets["aks"].id : null
  description = "AKS 서브넷 ID"
}

# Gateway 서브넷 ID를 별도로 출력
output "gateway_subnet_id" {
  description = "Gateway 서브넷의 ID"
  value       = azurerm_subnet.subnets["gateway"].id
} 