terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

module "spoke_network" {
  source = "./modules/spoke-network"

  project_name      = var.spoke_project_name
  spoke_rg         = var.spoke_rg
  location         = var.location
  environment      = var.environment
  spoke_vnet_name  = var.spoke_vnet_name
  spoke_vnet_prefix = var.spoke_vnet_prefix
  
  subnets = {
    aks = {
      address_prefixes = [var.aks_subnet_prefix]
      service_endpoints = ["Microsoft.ContainerRegistry"]
    }
    app = {
      address_prefixes = [var.app_subnet_prefix]
    }
    db = {
      address_prefixes = [var.db_subnet_prefix]
    }
    endpoints = {
      address_prefixes = [var.endpoints_subnet_prefix]
    }
    appgw = {
      address_prefixes = [var.appgw_subnet_prefix]
    }
    loadbalancer = {
      address_prefixes = [var.loadbalancer_subnet_prefix]
    }
  }

  # 추가 필수 변수들
  aks_subnet_prefix = var.aks_subnet_prefix
  app_subnet_prefix = var.app_subnet_prefix
  db_subnet_prefix = var.db_subnet_prefix
  endpoints_subnet_prefix = var.endpoints_subnet_prefix
  appgw_subnet_prefix = var.appgw_subnet_prefix
  loadbalancer_subnet_prefix = var.loadbalancer_subnet_prefix

  resource_group_name = var.spoke_rg
  enable_hub_peering = true  # Hub와의 피어링 활성화
  hub_vnet_id = var.hub_vnet_id
  hub_resource_group_name = var.hub_resource_group_name
  hub_vnet_name = var.hub_vnet_name
  firewall_private_ip = var.firewall_private_ip
} 