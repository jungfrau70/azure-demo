# User Assigned Managed Identity 생성
resource "azurerm_user_assigned_identity" "jumpbox_identity" {
  name                = "id-jumpbox-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Public IP 생성
resource "azurerm_public_ip" "jumpbox_pip" {
  name                = "pip-jumpbox-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "jumpbox_nic" {
  name                = "nic-jumpbox-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.jumpbox_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                  = "vm-jumpbox-${var.environment}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = "Standard_B2s"
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.jumpbox_nic.id]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.jumpbox_identity.id]
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    
    # 시스템 업데이트
    apt-get update
    apt-get upgrade -y

    # Azure CLI 설치
    curl -sL https://aka.ms/InstallAzureCLI | bash

    # Kubectl 설치
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/

    # 기타 유용한 도구 설치
    apt-get install -y \
      jq \
      git \
      curl \
      wget \
      unzip \
      net-tools \
      dnsutils \
      traceroute \
      tcpdump

    # Azure CLI 확장 설치
    az extension add --name aks-preview

    # 터널링 활성화
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    sysctl -p
    EOF
  )
}

# NSG 생성 및 규칙 추가
resource "azurerm_network_security_group" "jumpbox_nsg" {
  name                = "nsg-jumpbox-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "22"
    source_address_prefix     = "*"  # 프로덕션에서는 특정 IP 범위로 제한하는 것을 권장
    destination_address_prefix = "*"
  }
}

# NIC와 NSG 연결
resource "azurerm_network_interface_security_group_association" "jumpbox_nsg_association" {
  network_interface_id      = azurerm_network_interface.jumpbox_nic.id
  network_security_group_id = azurerm_network_security_group.jumpbox_nsg.id
} 