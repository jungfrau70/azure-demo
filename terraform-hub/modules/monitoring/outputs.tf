output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.hub.id
  description = "Log Analytics Workspace ID"
}

output "log_analytics_workspace_key" {
  value       = azurerm_log_analytics_workspace.hub.primary_shared_key
  description = "Log Analytics Workspace Primary Key"
  sensitive   = true
}

output "action_group_id" {
  value       = azurerm_monitor_action_group.hub_action_group.id
  description = "Monitor Action Group ID"
} 