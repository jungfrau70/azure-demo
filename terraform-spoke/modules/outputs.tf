# 모듈에서 외부로 노출할 값들을 여기에 정의합니다
output "module_name" {
  description = "모듈 이름"
  value       = "terraform-spoke"
}

# 추가 아웃풋들은 필요에 따라 여기에 정의됩니다 

output "resource_group_name" {
  value       = azurerm_resource_group.spoke.name
  description = "생성된 리소스 그룹 이름"
}

output "vnet_name" {
  value       = azurerm_virtual_network.spoke.name
  description = "생성된 가상 네트워크 이름"
}

output "vnet_id" {
  value       = azurerm_virtual_network.spoke.id
  description = "생성된 가상 네트워크 ID"
}

output "subnet_ids" {
  value = {
    for subnet in azurerm_subnet.subnets :
    subnet.name => subnet.id
  }
  description = "생성된 서브넷 ID 맵"
} 