terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_storage_account" "aks" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind            = "FileStorage"

  network_rules {
    default_action = "Deny"
    virtual_network_subnet_ids = [var.subnet_id]
  }
}

resource "azurerm_storage_share" "aks" {
  name                 = var.share_name
  storage_account_name = azurerm_storage_account.aks.name
  quota                = 100
}

resource "kubernetes_storage_class" "azure_file" {
  metadata {
    name = var.storage_class_name
  }

  storage_provisioner = "kubernetes.io/azure-file"
  reclaim_policy     = "Delete"
  parameters = {
    skuName = "Premium_LRS"
  }
} 