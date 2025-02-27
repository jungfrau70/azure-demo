resource "azurerm_public_ip" "bastion" {
  name                = "Bastion-PIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                = "Standard"

  tags = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bastionhost"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id           = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }

  tags = var.tags
}

resource "azurerm_virtual_machine" "jumpbox" {
  name                  = "Jumpbox-VM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.jumpbox.id]
  vm_size              = "Standard_B2s"

  storage_os_disk {
    name              = "Jumpbox-VM-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = 128
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_profile {
    computer_name  = "jumpbox"
    admin_username = "azureuser"
    admin_password = var.jumpbox_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = var.tags
} 