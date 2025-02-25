output "bastion_nsg_id" {
  value       = azurerm_network_security_group.bastion_nsg.id
  description = "Bastion NSG ID"
}

output "jumpbox_nsg_id" {
  value       = azurerm_network_security_group.jumpbox_nsg.id
  description = "Jumpbox NSG ID"
}

output "firewall_private_ip" {
  description = "Hub Firewall의 프라이빗 IP 주소"
  value       = azurerm_firewall.hub.ip_configuration[0].private_ip_address
} 