# Spoke 리소스 그룹
resource "azurerm_resource_group" "spoke_rg" {
  name     = var.spoke_rg
  location = var.location
}

# Spoke VNet
resource "azurerm_virtual_network" "spoke" {
  name                = var.spoke_vnet_name
  resource_group_name = var.spoke_rg
  location            = var.location
  address_space       = [var.spoke_vnet_prefix]
}

# 서브넷 생성
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key == "gateway" ? "GatewaySubnet" : "snet-${each.key}"
  resource_group_name  = var.spoke_rg
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = lookup(each.value, "service_endpoints", [])

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name = delegation.value.service
      }
    }
  }
}

# NSG 생성 - Gateway 서브넷 제외
resource "azurerm_network_security_group" "nsg" {
  for_each = {
    for k, v in var.subnets : k => v
    if k != "gateway"
  }

  name                = "nsg-${each.key}"
  location            = var.location
  resource_group_name = var.spoke_rg
}

# NSG 연결 - Gateway 서브넷 제외
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = {
    for k, v in var.subnets : k => v
    if k != "gateway"
  }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

# Route Table 생성
resource "azurerm_route_table" "aks" {
  name                = "rt-aks"
  location            = var.location
  resource_group_name = var.resource_group_name

  route {
    name                   = "to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type         = "VirtualAppliance"
    next_hop_in_ip_address = coalesce(var.firewall_private_ip, "10.0.1.4")
  }
}

# Route Table을 AKS 서브넷에 연결
resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = azurerm_subnet.subnets["aks"].id
  route_table_id = azurerm_route_table.aks.id
}

# Hub VNet과 피어링 설정
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  count                     = var.enable_hub_peering ? 1 : 0
  name                      = "spoke-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = var.hub_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic     = true
  allow_gateway_transit       = false
  use_remote_gateways        = true
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  count                     = var.enable_hub_peering ? 1 : 0
  name                      = "hub-to-spoke"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic     = true
  allow_gateway_transit       = true
  use_remote_gateways        = false
}

# AKS NSG 규칙 추가
resource "azurerm_network_security_rule" "aks_outbound" {
  name                        = "allow-aks-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = var.spoke_rg
  network_security_group_name = azurerm_network_security_group.nsg["aks"].name
}

resource "azurerm_network_security_rule" "aks_inbound" {
  name                        = "allow-aks-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "AzureLoadBalancer"
  destination_address_prefix = "*"
  resource_group_name         = var.spoke_rg
  network_security_group_name = azurerm_network_security_group.nsg["aks"].name
} 