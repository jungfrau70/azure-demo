variable "project_name" {
  type        = string
  description = "프로젝트 이름"
}

variable "spoke_rg" {
  type        = string
  description = "Spoke 리소스 그룹 이름"
}

variable "location" {
  type        = string
  description = "Azure 리전"
}

variable "environment" {
  type        = string
  description = "환경 (dev, prod 등)"
}

variable "spoke_vnet_name" {
  type        = string
  description = "Spoke VNet 이름"
}

variable "spoke_vnet_prefix" {
  type        = string
  description = "Spoke VNet 주소 공간"
}

variable "app_subnet_prefix" {
  type        = string
  description = "애플리케이션 서브넷 주소 범위"
}

variable "db_subnet_prefix" {
  type        = string
  description = "데이터베이스 서브넷 주소 범위"
}

variable "aks_subnet_name" {
  type        = string
  description = "AKS 서브넷 이름"
  default     = "aks-subnet"
}

variable "aks_subnet_prefix" {
  type        = string
  description = "AKS 서브넷 주소 공간"
}

variable "appgw_subnet_name" {
  type        = string
  description = "Application Gateway 서브넷 이름"
  default     = "appgw-subnet"
}

variable "appgw_subnet_prefix" {
  type        = string
  description = "Application Gateway 서브넷 주소 공간"
}

variable "endpoints_subnet_name" {
  type        = string
  description = "Private Endpoints 서브넷 이름"
  default     = "endpoints-subnet"
}

variable "endpoints_subnet_prefix" {
  type        = string
  description = "Private Endpoints 서브넷 주소 공간"
}

variable "loadbalancer_subnet_name" {
  type        = string
  description = "Load Balancer 서브넷 이름"
  default     = "loadbalancer-subnet"
}

variable "loadbalancer_subnet_prefix" {
  type        = string
  description = "Load Balancer 서브넷 주소 공간"
}

variable "hub_vnet_id" {
  type        = string
  description = "Hub VNet ID"
  default     = null
}

variable "subnets" {
  type = map(object({
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name    = string
      service = string
    }), null)
  }))
  description = "서브넷 구성"
}

variable "resource_group_name" {
  type        = string
  description = "리소스 그룹 이름"
}

variable "firewall_private_ip" {
  type        = string
  description = "Firewall private IP"
  default     = null
}

variable "enable_hub_peering" {
  type        = bool
  description = "Hub VNet 피어링 활성화 여부"
  default     = false
}

variable "hub_resource_group_name" {
  type        = string
  description = "Hub 리소스 그룹 이름"
  default     = null
}

variable "hub_vnet_name" {
  type        = string
  description = "Hub VNet 이름"
  default     = null
} 