terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {}  # backend.hcl에서 설정을 가져옴
}

# Azure Provider 설정
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# 리소스 그룹
resource "azurerm_resource_group" "hub_rg" {
  name     = var.rg_hub_name
  location = var.location
}

# Hub VNet 및 서브넷
resource "azurerm_virtual_network" "hub" {
  name                = var.vnet_hub_name
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  address_space       = [var.vnet_hub_prefix]

  tags = {
    environment = var.environment_name
    network     = "hub"
    project     = var.project_name
  }
}

resource "azurerm_subnet" "fw_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_fw_prefix]
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = var.subnet_bastion_name
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_bastion_prefix]
}

resource "azurerm_subnet" "jumpbox_subnet" {
  name                 = "jumpbox-subnet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.subnet_jumpbox_prefix]
}

# 랜덤 문자열 생성
resource "random_string" "resource_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Key Vault
resource "azurerm_key_vault" "hub_kv" {
  name                        = "${var.project_name}${var.environment_name}kv${random_string.resource_suffix.result}"
  location                    = azurerm_resource_group.hub_rg.location
  resource_group_name         = azurerm_resource_group.hub_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enabled_for_disk_encryption = true
  
  # Soft Delete 및 Purge 보호 설정
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enable_rbac_authorization   = false

  # Key Vault 접근 정책
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Recover", "Purge"
    ]

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Purge"
    ]

    certificate_permissions = [
      "Get", "List", "Create", "Delete", "Update", "Recover", "Purge"
    ]
  }

  # 네트워크 규칙
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    environment = var.environment_name
    project     = var.project_name
  }
}

# ACR
resource "azurerm_container_registry" "hub_acr" {
  name                = "${var.project_name}acr${random_string.resource_suffix.result}"
  resource_group_name = azurerm_resource_group.hub_rg.name
  location            = azurerm_resource_group.hub_rg.location
  sku                = "Premium"
  admin_enabled      = false
}

data "azurerm_client_config" "current" {}

module "network" {
  source = "./modules/network"
  hub_rg                = var.rg_hub_name
  location             = var.location
  project_name         = var.project_name
  environment          = var.environment_name 
  hub_vnet_name        = "${var.project_name}-hub-vnet"
  
  hub_vnet_prefix      = var.vnet_hub_prefix
  fw_subnet_prefix     = var.subnet_fw_prefix
  bastion_subnet_prefix = var.subnet_bastion_prefix
  jumpbox_subnet_prefix = var.subnet_jumpbox_prefix

  fw_name              = "${var.project_name}-hub-fw"

  resource_group_name = var.rg_hub_name
  vnet_name          = "${var.project_name}-hub-vnet"
  address_space      = [var.vnet_hub_prefix]
  
  subnets = {
    AzureFirewallSubnet = {
      name             = "AzureFirewallSubnet"
      address_prefixes = [var.subnet_fw_prefix]
    }
    AzureBastionSubnet = {
      name             = "AzureBastionSubnet"
      address_prefixes = [var.subnet_bastion_prefix]
    }
    JumpboxSubnet = {
      name             = "jumpbox-subnet"
      address_prefixes = [var.subnet_jumpbox_prefix]
    }
  }
  depends_on = [azurerm_resource_group.hub_rg]
}

module "security" {
  source = "./modules/security"

  prefix              = var.vnet_hub_prefix
  resource_group_name = azurerm_resource_group.hub_rg.name
  location            = var.location
  environment         = var.environment_name
  project_name        = var.project_name
  hub_rg             = var.rg_hub_name
  bastion_nsg_name   = var.nsg_bastion_name
  jumpbox_nsg_name   = var.nsg_jumpbox_name
  bastion_subnet_id  = azurerm_subnet.bastion_subnet.id
  jumpbox_subnet_id  = azurerm_subnet.jumpbox_subnet.id
  fw_subnet_id       = module.network.fw_subnet_id
  tags               = var.tags

  depends_on = [azurerm_resource_group.hub_rg, module.network]
}

module "monitoring" {
  source = "./modules/monitoring"
  
  prefix              = var.vnet_hub_prefix
  resource_group_name = azurerm_resource_group.hub_rg.name
  location           = var.location
  environment        = var.environment_name
  project_name       = var.project_name
  
  log_analytics_retention_days = var.log_analytics_retention_days
  monitor_action_group_name    = var.monitor_action_group_name
  monitor_email_receivers      = var.monitor_email_receivers
  alert_scopes                = [azurerm_container_registry.hub_acr.id]
  vnet_id                     = module.network.hub_vnet_id
}

module "backup" {
  source = "./modules/backup"
  
  resource_group_name = azurerm_resource_group.hub_rg.name
  location           = var.location
  resource_suffix    = random_string.resource_suffix.result
}

module "dns" {
  source = "./modules/dns"
  
  resource_group_name = azurerm_resource_group.hub_rg.name
  hub_vnet_id        = azurerm_virtual_network.hub.id
}

# Spoke1 VNet 데이터 소스 추가
data "azurerm_virtual_network" "spoke1" {
  name                = var.vnet_spoke1_name
  resource_group_name = "rg-spoke1"  # Spoke1의 리소스 그룹 이름
}

# VNet 피어링 설정 (Hub <-> Spoke1)
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "hub-to-spoke1"
  resource_group_name       = azurerm_resource_group.hub_rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = data.azurerm_virtual_network.vnet_spoke1_name.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Spoke VNet 데이터 소스 추가
data "azurerm_virtual_network" "vnet_spoke1_name" {
  name                = var.vnet_spoke1_name
  resource_group_name = "rg-spoke1"  # Spoke1의 리소스 그룹 이름
}

# VNet 피어링 설정
resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                      = "hub-to-spoke2"
  resource_group_name       = azurerm_resource_group.hub_rg.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = data.azurerm_virtual_network.vnet_spoke2_name.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Spoke VNet 데이터 소스 추가
data "azurerm_virtual_network" "vnet_spoke2_name" {
  name                = var.vnet_spoke2_name
  resource_group_name = "rg-spoke2"  # Spoke1의 리소스 그룹 이름
}

# Output 변수들
output "resource_group_name" {
  value = azurerm_resource_group.hub_rg.name
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "keyvault_id" {
  value = azurerm_key_vault.hub_kv.id
}

output "acr_id" {
  value = azurerm_container_registry.hub_acr.id
}

output "fw_private_ip" {
  description = "Hub Firewall의 프라이빗 IP 주소"
  value       = module.security.firewall_private_ip
}

output "log_analytics_workspace_id" {
  value = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_workspace_key" {
  value     = module.monitoring.log_analytics_workspace_key
  sensitive = true
}

output "monitor_action_group_id" {
  value = module.monitoring.action_group_id
}

# Azure Application Gateway 설정
resource "azurerm_application_gateway" "app_gateway" {
  name                = var.app_gateway_name
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name

  sku {
    name     = var.app_gateway_sku_name
    tier     = var.app_gateway_sku_tier
    capacity = var.app_gateway_capacity
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  frontend_port {
    name = "frontendPort"
    port = var.app_gateway_frontend_port
  }

  frontend_ip_configuration {
    name                 = "appGatewayFrontendIP"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool {
    name = "backendAddressPool"
  }

  backend_http_settings {
    name                  = "httpSettings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "appGatewayHttpListener"
    frontend_ip_configuration_name = "appGatewayFrontendIP"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "appGatewayHttpListener"
    backend_address_pool_name  = "backendAddressPool"
    backend_http_settings_name = "httpSettings"
    priority                   = 100
  }

  tags = {
    environment = var.environment_name
    project     = var.project_name
  }
}

# Private DNS Zone 및 Private Endpoint 설정
resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = var.private_dns_zone_name
  resource_group_name = azurerm_resource_group.hub_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  name                  = "aks-link"
  resource_group_name   = azurerm_resource_group.hub_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_resource_group" "rg_spoke2" {
  name     = "rg-spoke2"
  location = var.location
}

resource "azurerm_virtual_network" "vnet_spoke2_name" {
  name                = var.vnet_spoke2_name
  address_space       = [var.vnet_spoke2_prefix]
  location            = azurerm_resource_group.rg_spoke2.location
  resource_group_name = azurerm_resource_group.rg_spoke2.name
}

resource "azurerm_subnet" "snet_aks_private" {
  name                 = "snet-aks-private"
  resource_group_name  = azurerm_resource_group.rg_spoke2.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke2_name.name
  address_prefixes     = [var.subnet_aks_private_prefix]
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.private_endpoint_name
  location            = azurerm_resource_group.rg_spoke2.location
  resource_group_name = azurerm_resource_group.rg_spoke2.name
  subnet_id           = azurerm_subnet.snet_aks_private.id

  private_service_connection {
    name                           = var.private_connection_name
    private_connection_resource_id = data.azurerm_kubernetes_cluster.aks_cluster.id
    subresource_names              = ["management"]
    is_manual_connection           = false
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  allocation_method   = "Static"

  sku = "Standard"

  tags = {
    environment = var.environment_name
    project     = var.project_name
  }
}

data "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  resource_group_name = var.aks_resource_group_name
}

resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = "app-gateway-subnet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
} 