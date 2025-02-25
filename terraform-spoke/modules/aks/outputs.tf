output "cluster_id" {
  description = "AKS 클러스터 ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "AKS 클러스터 이름"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  description = "AKS kubeconfig"
  value       = azurerm_kubernetes_cluster.aks.kube_config
  sensitive   = true
}

output "identity_id" {
  description = "AKS Managed Identity ID"
  value       = azurerm_user_assigned_identity.aks.id
}

output "identity_principal_id" {
  description = "AKS Managed Identity Principal ID"
  value       = azurerm_user_assigned_identity.aks.principal_id
}

output "node_resource_group" {
  description = "AKS 노드 리소스 그룹 이름"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}
