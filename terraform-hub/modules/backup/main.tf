resource "azurerm_data_protection_backup_vault" "backup_vault" {
  name                = "hub-backup-vault"
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}

resource "azurerm_recovery_services_vault" "vault" {
  name                = "hub-recovery-vault"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
}

resource "azurerm_storage_account" "backup" {
  name                     = "hubbackup${var.resource_suffix}"
  resource_group_name      = var.resource_group_name
  location                = var.location
  account_tier            = "Standard"
  account_replication_type = "GRS"
} 