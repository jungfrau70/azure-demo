terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# AKS 클러스터용 Managed Identity
resource "azurerm_user_assigned_identity" "aks" {
  name                = var.aks_identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

# AKS 클러스터
resource "azurerm_kubernetes_cluster" "aks" {
  name                              = var.cluster_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.dns_prefix
  private_cluster_enabled           = true
  private_dns_zone_id               = "System"
  kubernetes_version                = var.kubernetes_version
  sku_tier                          = var.sku_tier
  role_based_access_control_enabled = true

  default_node_pool {
    name                = var.default_node_pool.name
    vm_size             = var.default_node_pool.vm_size
    vnet_subnet_id      = var.subnet_id
    max_pods            = 30
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    type                = "VirtualMachineScaleSets"
    zones               = [1, 2, 3]
    enable_auto_scaling = true
    min_count          = var.default_node_pool.min_count
    max_count          = var.default_node_pool.max_count
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting"
    dns_service_ip    = "10.2.16.10"
    service_cidr      = "10.2.16.0/24"
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  # private_cluster_enabled = true
  # private_dns_zone_id     = "System"

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  # ACR 연동
  azure_policy_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = var.tags

  timeouts {
    create = "60m"
    update = "60m"
    read   = "5m"
    delete = "60m"
  }
}
