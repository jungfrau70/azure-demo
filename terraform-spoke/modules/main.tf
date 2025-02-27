terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# AWS 프로바이더 설정
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = var.default_tags
  }
}

# 여기에 실제 리소스 설정이 들어갈 예정입니다 

resource "azurerm_resource_group" "spoke" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "spoke" {
  name                = var.vnet_name
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.key
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = each.value.address_prefixes
}

# Jumpbox 서브넷 생성
resource "azurerm_subnet" "jumpbox_subnet" {
  name                 = "snet-jumpbox"
  resource_group_name  = var.rg_hub_name        # Hub 리소스 그룹 사용
  virtual_network_name = var.vnet_hub_name      # Hub VNet 사용
  address_prefixes     = ["10.0.10.0/24"]      # Hub VNet의 주소 범위에 맞게 수정
}

module "jumpbox" {
  source = "./jumpbox"

  environment         = var.environment
  location           = var.location
  resource_group_name = var.rg_hub_name         # Hub 리소스 그룹 사용
  jumpbox_subnet_id   = azurerm_subnet.jumpbox_subnet.id
  admin_username     = var.jumpbox_admin_username
  ssh_public_key     = var.jumpbox_ssh_public_key
} 