output "jumpbox_private_ip" {
  value = azurerm_network_interface.jumpbox_nic.private_ip_address
}

output "jumpbox_public_ip" {
  value = azurerm_public_ip.jumpbox_pip.ip_address
}

output "jumpbox_id" {
  value = azurerm_linux_virtual_machine.jumpbox.id
}

output "jumpbox_identity_id" {
  value = azurerm_user_assigned_identity.jumpbox_identity.id
} 