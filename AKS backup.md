AKS 백업은 Azure Backup 서비스를 통해 다음과 같이 이루어집니다:

1. **백업 구성 요소**:
```hcl
# Hub에 백업 볼트 생성
resource "azurerm_data_protection_backup_vault" "backup_vault" {
  name                = "hub-backup-vault"
  resource_group_name = var.resource_group_name
  location            = var.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}

# 백업 정책 설정
resource "azurerm_data_protection_backup_policy_kubernetes_cluster" "aks_policy" {
  name     = "aks-backup-policy"
  vault_id = azurerm_data_protection_backup_vault.backup_vault.id

  backup_repeating_time_intervals = ["R/2023-01-01T00:00:00+00:00/P1D"] # 매일 백업
  default_retention_duration      = "P30D"                               # 30일 보관

  retention_rule {
    name     = "weekly"
    duration = "P12W"                                                    # 12주 보관
    priority = 25
    criteria {
      absolute_criteria = "FirstOfWeek"
    }
  }
}
```

2. **백업 대상 설정**:
```hcl
# Spoke에서 AKS 클러스터 백업 인스턴스 생성
resource "azurerm_data_protection_backup_instance_kubernetes" "aks_backup" {
  name                 = "aks-backup"
  vault_id             = var.backup_vault_id
  location             = var.location
  kubernetes_cluster_id = var.aks_cluster_id
  backup_policy_id     = var.backup_policy_id
}
```

3. **백업 내용**:
- Kubernetes 리소스 (Deployments, Services, ConfigMaps 등)
- 영구 볼륨 (PV) 데이터
- RBAC 설정
- 사용자 정의 리소스 정의 (CRD)

4. **백업 프로세스**:
- 스케줄에 따라 자동 백업 실행
- 증분 백업으로 저장 공간 최적화
- 백업 데이터는 Azure Backup 볼트에 안전하게 저장

5. **복구 옵션**:
- 전체 클러스터 복구
- 특정 네임스페이스 복구
- 선택적 리소스 복구
- 다른 클러스터로 복구

6. **모니터링**:
```hcl
# 백업 상태 모니터링을 위한 알림 설정
resource "azurerm_monitor_activity_log_alert" "backup_alert" {
  name                = "aks-backup-alert"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_data_protection_backup_instance_kubernetes.aks_backup.id]
  description         = "AKS 백업 실패 알림"

  criteria {
    category       = "Administrative"
    level          = "Error"
    status         = "Failed"
    resource_type  = "Microsoft.DataProtection/backupVaults/backupInstances"
  }

  action {
    action_group_id = var.action_group_id
  }
}
```

이러한 백업 구성을 통해:
- 정기적인 자동 백업
- 데이터 보호 및 복구 기능
- 백업 상태 모니터링
- 장기 보관 정책 관리

가 가능합니다.
