variable "resource_group_name" {
  description = "리소스 그룹 이름"
  type        = string
}

variable "location" {
  description = "리소스 위치"
  type        = string
}

variable "aks_cluster_id" {
  description = "AKS 클러스터 ID"
  type        = string
}

variable "backup_vault_id" {
  description = "백업 볼트 ID"
  type        = string
}

variable "backup_policy_id" {
  description = "백업 정책 ID"
  type        = string
}

variable "recovery_vault_name" {
  description = "복구 서비스 볼트 이름"
  type        = string
} 