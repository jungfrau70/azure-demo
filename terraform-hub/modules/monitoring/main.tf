# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "hub" {
  name                = "${var.project_name}-hub-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  daily_quota_gb     = 10
  
  tags = {
    environment = var.environment
    project     = var.project_name
  }
}

# Monitor Action Group
resource "azurerm_monitor_action_group" "hub_action_group" {
  name                = var.monitor_action_group_name
  resource_group_name = var.resource_group_name
  short_name         = "hubaction"
  enabled            = true
  location           = "global"

  dynamic "email_receiver" {
    for_each = var.monitor_email_receivers
    content {
      name                    = email_receiver.value.name
      email_address          = email_receiver.value.email_address
      use_common_alert_schema = email_receiver.value.use_common_alert_schema
    }
  }
}

# Azure Monitor 기본 알림 설정
resource "azurerm_monitor_metric_alert" "hub_cpu_alert" {
  name                = "hub-cpu-alert"
  resource_group_name = var.resource_group_name
  scopes             = var.alert_scopes
  description        = "CPU 사용량이 임계값을 초과했습니다"

  criteria {
    metric_namespace = "Microsoft.ContainerRegistry/registries"
    metric_name      = "AgentPoolCPUTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.hub_action_group.id
  }
}

# Prometheus 데이터 수집 엔드포인트
resource "azurerm_monitor_data_collection_endpoint" "prometheus" {
  name                = "${var.project_name}-prometheus-dce"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind               = "Linux"
}

# Prometheus 작업 영역
resource "azurerm_monitor_workspace" "prometheus" {
  name                = "${var.project_name}-prometheus"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Prometheus 데이터 수집 규칙
resource "azurerm_monitor_data_collection_rule" "prometheus" {
  name                = "${var.project_name}-prometheus-dcr"
  resource_group_name = var.resource_group_name
  location            = var.location

  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.prometheus.id

  data_sources {
    prometheus_forwarder {
      name    = "prometheus"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.prometheus.id
      name              = "prometheus-metrics"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["prometheus-metrics"]
  }
}

# 클러스터 상태 메트릭 알림 - 일시적으로 주석 처리
/*
resource "azurerm_monitor_metric_alert" "cluster_health" {
  name                = "${var.project_name}-cluster-health"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_monitor_workspace.prometheus.id]
  description         = "클러스터 CPU 사용량 알림"
  
  criteria {
    metric_namespace = "Microsoft.Monitor/accounts"
    metric_name      = "InsertedMetricsCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.hub_action_group.id
  }
}
*/

# 네트워크 메트릭 알림 설정
resource "azurerm_monitor_metric_alert" "network_alert" {
  name                = "network-throughput-alert"
  resource_group_name = var.resource_group_name
  scopes             = var.alert_scopes
  description        = "네트워크 처리량이 임계값을 초과했습니다"

  criteria {
    metric_namespace = "Microsoft.ContainerRegistry/registries"
    metric_name      = "TotalPullCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 1000000
  }

  action {
    action_group_id = azurerm_monitor_action_group.hub_action_group.id
  }
} 