Azure 리소스를 Terraform으로 구성하기 위해 파일들을 생성하고 수정하겠습니다. 
먼저 네트워크 구성부터 시작하겠습니다.

```terraform:1_Azure_resources/network.tf
# Hub VNet 및 서브넷 구성
resource "azurerm_virtual_network" "hub" {
  name                = "Hub_VNET"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/22"]

  tags = var.tags
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.128/26"]
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.0/26"]
}

resource "azurerm_subnet" "jumpbox" {
  name                 = "JumpboxSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.0.64/26"]
}

# Spoke VNet 및 서브넷 구성
resource "azurerm_virtual_network" "spoke" {
  name                = "Spoke_VNET"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.1.0.0/22"]

  tags = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "loadbalancer" {
  name                 = "loadbalancer-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.1.0/28"]
}

resource "azurerm_subnet" "appgw" {
  name                 = "app-gw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_subnet" "endpoints" {
  name                 = "endpoints-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.1.16/28"]
}

# VNet Peering 구성
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "hub-to-spoke"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "spoke-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
}
```

NSG 구성을 위한 파일을 생성하겠습니다:

```terraform:1_Azure_resources/nsg.tf
# Bastion NSG
resource "azurerm_network_security_group" "bastion" {
  name                = "Bastion_NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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

  tags = var.tags
}

# AKS NSG
resource "azurerm_network_security_group" "aks" {
  name                = "Aks_NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.tags
}

# Application Gateway NSG
resource "azurerm_network_security_group" "appgw" {
  name                = "Appgw_NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-Internet-Inbound-HTTP-HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = var.tags
}
```

AKS 클러스터 구성을 위한 파일을 생성하겠습니다:

```terraform:1_Azure_resources/aks.tf
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "private-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "private-aks"

  default_node_pool {
    name           = "default"
    node_count     = 3
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  private_cluster_enabled = true

  tags = var.tags
}
```

Bastion 및 Jumpbox VM 구성을 위한 파일을 생성하겠습니다:

```terraform:1_Azure_resources/bastion.tf
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
```

변수 파일에 추가할 내용입니다:

```terraform:1_Azure_resources/variables.tf
variable "jumpbox_password" {
  type        = string
  description = "Jumpbox VM 관리자 비밀번호"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Azure AD 테넌트 ID"
}

variable "subscription_id" {
  type        = string
  description = "Azure 구독 ID"
}
```

이러한 Terraform 구성은 기본적인 인프라를 설정합니다. 추가로 필요한 구성이나 수정사항이 있다면 말씀해 주세요.
