# AKS 백업 구성은 일시적으로 비활성화
/*
resource "azurerm_backup_protected_vm" "aks_backup" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = var.recovery_vault_name
  source_vm_id       = var.aks_cluster_id
  backup_policy_id   = var.backup_policy_id
}

resource "azurerm_backup_container_storage_account" "aks_backup" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = var.recovery_vault_name
  storage_account_id  = var.aks_cluster_id
}
*/

# 재해 복구 구성 (비활성화)
/*
resource "azurerm_site_recovery_replicated_vm" "dr_vm" {
  name                                      = "aks-dr"
  resource_group_name                       = var.resource_group_name
  recovery_vault_name                       = var.recovery_vault_name
  source_recovery_fabric_name               = "primary-fabric"
  source_vm_id                             = var.aks_cluster_id
  source_recovery_protection_container_name = "primary-container"
  target_recovery_fabric_id                = var.target_recovery_fabric_id
  target_recovery_protection_container_id   = var.target_protection_container_id
  target_resource_group_id                 = var.target_resource_group_id
  recovery_replication_policy_id           = var.replication_policy_id
}

# Traffic Manager 구성
resource "azurerm_traffic_manager_profile" "dr" {
  name                   = "dr-traffic-manager"
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "dr-demo"
    ttl          = 100
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}
*/ 