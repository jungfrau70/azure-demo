output "app_service_plan_id" {
  value       = azurerm_service_plan.app_plan.id
  description = "App Service Plan ID"
}

output "app_service_plan_name" {
  value       = azurerm_service_plan.app_plan.name
  description = "App Service Plan 이름"
}

output "app_services" {
  value = {
    for app in azurerm_linux_web_app.apps :
    app.name => {
      id             = app.id
      default_host   = app.default_hostname
      identity       = try(app.identity, null)
    }
  }
  description = "App Service 정보"
}

output "app_insights" {
  value = {
    for insights in azurerm_application_insights.app_insights :
    insights.name => {
      id                  = insights.id
      instrumentation_key = insights.instrumentation_key
      connection_string   = insights.connection_string
    }
  }
  description = "Application Insights 정보"
}

output "key_vault_id" {
  value       = azurerm_key_vault.app_vault.id
  description = "Key Vault ID"
}

output "key_vault_uri" {
  value       = azurerm_key_vault.app_vault.vault_uri
  description = "Key Vault URI"
} 