#!/bin/bash

# Hub 모듈 구조 생성
mkdir -p terraform-hub/modules/{network,monitoring,security}

# Hub 네트워크 모듈
cat > terraform-hub/modules/network/main.tf << EOF
# Hub VNet 및 서브넷 생성
resource "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_rg
  location            = var.location
  address_space       = [var.hub_vnet_prefix]
}
EOF

# Spoke 모듈 구조 생성
mkdir -p terraform-spoke/modules/{network,aks,storage,gateway,application}

# Spoke 네트워크 모듈
cat > terraform-spoke/modules/network/main.tf << EOF
# Spoke VNet 및 서브넷 생성
resource "azurerm_virtual_network" "spoke" {
  name                = var.spoke_vnet_name
  resource_group_name = var.spoke_rg
  location            = var.location
  address_space       = [var.spoke_vnet_prefix]
}
EOF

echo "Terraform 프로젝트 구조가 생성되었습니다." 