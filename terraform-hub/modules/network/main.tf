# Hub VNet 생성
resource "azurerm_virtual_network" "hub" {
  name                = "hub-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]  # 일관된 주소 공간으로 수정

  tags = {
    environment = "shared"
    network     = "hub"
    project     = var.project_name
  }
}

# subnets 맵을 통해 서브넷 생성
locals {
  subnets = {
    AzureBastionSubnet = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.0.2.0/24"]
    }
    JumpboxSubnet = {
      name             = "jumpbox-subnet"
      address_prefixes = ["10.0.3.0/24"]
    }
  }
}

resource "azurerm_subnet" "subnets" {
  for_each = local.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = each.value.address_prefixes
}

# Bastion Host 생성
resource "azurerm_public_ip" "bastion" {
  name                = "${var.prefix}-bastion-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                = "Standard"
}

resource "azurerm_bastion_host" "main" {
  name                = "${var.prefix}-bastion"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id           = azurerm_subnet.subnets["AzureBastionSubnet"].id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

# 서브넷 생성
resource "azurerm_subnet" "fw_subnet" {
  name                 = "AzureFirewallSubnet"  # 이 이름은 고정되어야 함
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}
