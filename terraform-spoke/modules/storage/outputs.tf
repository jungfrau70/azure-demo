output "storage_account_id" {
  value       = azurerm_storage_account.aks.id
  description = "스토리지 계정 ID"
}

output "storage_account_name" {
  value       = azurerm_storage_account.aks.name
  description = "스토리지 계정 이름"
}

output "storage_share_name" {
  value       = azurerm_storage_share.aks.name
  description = "파일 공유 이름"
}

output "storage_class_name" {
  value       = kubernetes_storage_class.azure_file.metadata[0].name
  description = "Kubernetes 스토리지 클래스 이름"
} 