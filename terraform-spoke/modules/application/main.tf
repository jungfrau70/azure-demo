terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# Helm 배포
resource "helm_release" "app" {
  name       = "myapp"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
  version    = "1.0.0"
  namespace  = "default"

  values = [
    yamlencode({
      replicaCount = var.helm_values.replicaCount
      ingress = {
        enabled = var.helm_values.ingress.enabled
        hosts = [{
          host = var.helm_values.ingress.host
          paths = [{
            path = "/"
          }]
        }]
      }
    })
  ]

  set_sensitive {
    name  = "database.url"
    value = var.db_connection_string
  }
}

# App Service Plan 생성
resource "azurerm_service_plan" "app_plan" {
  name                = "plan-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type            = "Linux"
  sku_name           = "P1v2"
}

# Linux Web App 생성
resource "azurerm_linux_web_app" "apps" {
  for_each = var.applications

  name                = "app-${each.key}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    container_registry_use_managed_identity = true
    application_stack {
      docker_image_name = "${var.docker_image_name}:${var.app_version}"
      docker_registry_url = "https://${var.acr_login_server}"
    }
  }

  app_settings = merge(
    {
      "DOCKER_REGISTRY_SERVER_URL"          = "https://${var.acr_login_server}"
      "DOCKER_REGISTRY_SERVER_USERNAME"     = var.acr_username
      "DOCKER_REGISTRY_SERVER_PASSWORD"     = var.acr_password
      "APPINSIGHTS_INSTRUMENTATIONKEY"      = azurerm_application_insights.app_insights[each.key].instrumentation_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app_insights[each.key].connection_string
    },
    each.value.app_settings
  )

  tags = var.tags
}

# Application Insights 생성
resource "azurerm_application_insights" "app_insights" {
  for_each = var.applications

  name                = "appi-${each.key}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  tags               = var.tags
}

# Key Vault 생성
resource "azurerm_key_vault" "app_vault" {
  name                = var.keyvault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id          = data.azurerm_client_config.current.tenant_id
  sku_name           = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete"
    ]
  }

  tags = var.tags
}

# 현재 Azure 설정 데이터 소스
data "azurerm_client_config" "current" {}
