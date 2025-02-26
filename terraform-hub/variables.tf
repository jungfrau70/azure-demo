# Azure 로그인 정보
variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

# 프로젝트 설정
variable "project_name" {
  type        = string
  description = "프로젝트 이름"
}

variable "location" {
  type        = string
  description = "Azure 리전"
}

# Hub 네트워크 설정
variable "rg_hub_name" {
  type        = string
  description = "Hub 리소스 그룹 이름"
}

variable "vnet_hub_name" {
  type        = string
  description = "Hub VNet 이름"
}

variable "subnet_fw_name" {
  type        = string
  description = "Firewall 서브넷 이름"
}

variable "subnet_bastion_name" {
  type        = string
  description = "Bastion 서브넷 이름"
  default     = "AzureBastionSubnet"
}

variable "vnet_hub_prefix" {
  type        = string
  description = "Hub VNet 주소 공간"
}

variable "subnet_fw_prefix" {
  type        = string
  description = "Firewall 서브넷 주소 공간"
}

variable "subnet_bastion_prefix" {
  type        = string
  description = "Bastion 서브넷 주소 공간"
}

variable "subnet_jumpbox_prefix" {
  type        = string
  description = "Jumpbox 서브넷 주소 공간"
}

variable "subnet_keyvault_prefix" {
  type        = string
  description = "KeyVault 서브넷 주소 공간"
}

# NSG 설정
variable "nsg_bastion_name" {
  type        = string
  description = "Bastion NSG 이름"
  default     = "Bastion_NSG"
}

variable "nsg_jumpbox_name" {
  type        = string
  description = "Jumpbox NSG 이름"
  default     = "Jumpbox_NSG"
}

# 인프라 설정
variable "fw_name" {
  type        = string
  description = "Azure Firewall 이름"
  default     = "azure-firewall"
}

variable "log_analytics_workspace_name" {
  type        = string
  description = "Log Analytics Workspace 이름"
  default     = "hub-law"
}

variable "log_analytics_retention_days" {
  type        = number
  description = "로그 보존 기간(일)"
  default     = 30
}

variable "monitor_action_group_name" {
  type        = string
  description = "Monitor Action Group 이름"
  default     = "hub-action-group"
}

variable "monitor_email_receivers" {
  type = list(object({
    name                    = string
    email_address          = string
    use_common_alert_schema = bool
  }))
  description = "알림을 받을 이메일 목록"
  default     = []
}

variable "security_rules_hub_name" {
  description = "보안 규칙 설정"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range         = string
    destination_port_range    = string
    source_address_prefix     = string
    destination_address_prefix = string
  }))
  default = []
}

variable "environment_name" {
  type        = string
  description = "환경 (shared, dev, prod 등)"
  default     = "shared"  # Hub는 공유 환경이므로 기본값을 shared로 설정
}

# Hub 프로젝트 변수
variable "project_hub_name" {
  type        = string
  description = "Hub 프로젝트 이름"
  default     = ""  # 환경 변수에서 가져올 수 있도록 기본값을 비워둠
}


variable "aks_node_size" {
  type        = string
  description = "AKS 노드 VM 크기"
  default     = "Standard_D2s_v3"
}

variable "tags" {
  description = "리소스에 적용될 태그"
  type        = map(string)
  default     = {}
}

variable "vnet_spoke1_name" {
  type        = string
  description = "Spoke VNet 이름"
} 

variable "vnet_spoke2_name" {
  type        = string
  description = "Spoke VNet 이름"
} 

# Application Gateway 관련 변수
variable "app_gateway_name" {
  description = "The name of the Application Gateway."
  type        = string
}

variable "app_gateway_sku_name" {
  description = "The SKU name of the Application Gateway."
  type        = string
}

variable "app_gateway_sku_tier" {
  description = "The SKU tier of the Application Gateway."
  type        = string
}

variable "app_gateway_capacity" {
  description = "The capacity of the Application Gateway."
  type        = number
}

variable "app_gateway_frontend_port" {
  description = "The frontend port of the Application Gateway."
  type        = number
}

# Public IP 관련 변수
variable "public_ip_name" {
  description = "The name of the public IP for the Application Gateway."
  type        = string
}

# Private DNS Zone 관련 변수
variable "private_dns_zone_name" {
  description = "The name of the Private DNS Zone."
  type        = string
}

# Private Endpoint 관련 변수
variable "private_endpoint_name" {
  description = "The name of the Private Endpoint."
  type        = string
}

variable "private_connection_name" {
  description = "The name of the Private Connection."
  type        = string
}

# AKS 클러스터 관련 변수
variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "aks_resource_group_name" {
  description = "The resource group name of the AKS cluster."
  type        = string
} 

variable "subnet_aks_private_prefix" {
  description = "The prefix of the AKS private subnet."
  type        = string
}

variable "vnet_spoke2_prefix" {
  description = "The prefix of the Spoke VNet."
  type        = string
}

variable "subnet_app_gateway_prefix" {
  description = "The prefix of the App Gateway subnet."
  type        = string
}

variable "subnet_app_gateway_name" {
  description = "The name of the App Gateway subnet."
  type        = string
}

