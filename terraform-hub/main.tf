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
  name                = "${var.project_name}-kv-${random_string.resource_suffix.result}"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  sku_name           = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = false
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