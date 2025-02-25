# Bastion NSG
resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "Bastion_NSG"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowGatewayManagerInbound"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range     = "443"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowLoadBalancerInbound"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowBastionHostCommunication"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range         = "*"
    destination_port_ranges    = ["8080", "5701"]
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowSshRdpOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range         = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureCloudOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureCloud"
  }

  # 기본 거부 규칙
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Jumpbox NSG
resource "azurerm_network_security_group" "jumpbox_nsg" {
  name                = "Jumpbox_NSG"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.2.0/24"  # Bastion 서브넷 CIDR로 수정
    destination_address_prefix = "*"
  }

  # 아웃바운드 인터넷 접근
  security_rule {
    name                       = "AllowInternetOutbound"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "*"
    destination_address_prefix = "Internet"
  }

  # 기본 거부 규칙
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range         = "*"
    destination_port_range    = "*"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# NSG 연결
resource "azurerm_subnet_network_security_group_association" "bastion_nsg_association" {
  subnet_id                 = var.bastion_subnet_id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "jumpbox_nsg_association" {
  subnet_id                 = var.jumpbox_subnet_id
  network_security_group_id = azurerm_network_security_group.jumpbox_nsg.id
}

# Azure Firewall 생성
resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-${var.project_name}-hub-fw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                = "Standard"
}

resource "azurerm_firewall" "hub" {
  name                = "${var.project_name}-hub-fw"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name           = "AZFW_VNet"
  sku_tier           = "Standard"

  ip_configuration {
    name                 = "${var.project_name}-fw-ipconfig"
    subnet_id            = var.fw_subnet_id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }

  tags = var.tags
}

# AKS 필수 아웃바운드 규칙
resource "azurerm_firewall_network_rule_collection" "aks" {
  name                = "aks-network-rules"
  azure_firewall_name = azurerm_firewall.hub.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Allow"

  rule {
    name                  = "allow-aks-azure-cloud"
    source_addresses      = ["10.2.0.0/16"]  # Spoke VNet 주소 공간
    destination_ports     = ["1194", "9000", "443"]
    destination_addresses = ["AzureCloud"]
    protocols            = ["UDP", "TCP"]
  }

  rule {
    name                  = "allow-aks-ntp"
    source_addresses      = ["10.2.0.0/16"]
    destination_ports     = ["123"]
    destination_addresses = ["*"]
    protocols            = ["UDP"]
  }
}

resource "azurerm_firewall_application_rule_collection" "aks" {
  name                = "aks-app-rules"
  azure_firewall_name = azurerm_firewall.hub.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Allow"

  rule {
    name = "allow-aks-required-fqdns"
    source_addresses = ["10.2.0.0/16"]

    target_fqdns = [
      "*.hcp.${var.location}.azmk8s.io",
      "mcr.microsoft.com",
      "*.data.mcr.microsoft.com",
      "management.azure.com",
      "login.microsoftonline.com",
      "packages.microsoft.com",
      "acs-mirror.azureedge.net",
      "*.monitoring.azure.com",
      "*.ods.opinsights.azure.com",
      "*.oms.opinsights.azure.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
} 