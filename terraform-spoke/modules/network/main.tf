# Spoke VNet 및 서브넷 생성
resource "azurerm_virtual_network" "spoke" {
  name                = var.spoke_vnet_name
  resource_group_name = var.spoke_rg
  location            = var.location
  address_space       = [var.spoke_vnet_prefix]
}

# 서브넷 생성
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = lookup(each.value, "service_endpoints", [])

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name

      service_delegation {
        name = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
        ]
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# NSG 생성 - Gateway 서브넷 제외
resource "azurerm_network_security_group" "nsg" {
  for_each = {
    for k, v in var.subnets : k => v
    if k != "gateway"  # Gateway 서브넷 제외
  }

  name                = "nsg-${each.key}"
  location            = var.location
  resource_group_name = var.spoke_rg
}

# NSG 연결 - Gateway 서브넷 제외
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = {
    for k, v in var.subnets : k => v
    if k != "gateway"  # Gateway 서브넷 제외
  }

  subnet_id                 = azurerm_subnet.subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id

  depends_on = [azurerm_network_security_group.nsg]
}

# NSG 규칙 추가
resource "azurerm_network_security_rule" "appgw_health" {
  name                        = "allow-appgw-health"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range          = "*"
  destination_port_range     = "65200-65535"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = var.spoke_rg
  network_security_group_name = azurerm_network_security_group.nsg["appgw"].name
}

resource "azurerm_network_security_rule" "appgw_web" {
  name                        = "allow-web-traffic"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range          = "*"
  destination_port_ranges    = ["80", "443"]
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name         = var.spoke_rg
  network_security_group_name = azurerm_network_security_group.nsg["appgw"].name
}

# Hub VNet 데이터 소스 수정
data "azurerm_virtual_network" "hub" {
  count               = var.enable_hub_peering ? 1 : 0
  name                = var.hub_vnet_name
  resource_group_name = var.hub_resource_group_name
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

  route {
    name                   = "to-vnetlocal"
    address_prefix         = var.spoke_vnet_prefix
    next_hop_type         = "VnetLocal"
  }
}

# Route Table을 AKS 서브넷에 연결
resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = azurerm_subnet.subnets["aks"].id
  route_table_id = azurerm_route_table.aks.id

  depends_on = [azurerm_subnet.subnets]
}
