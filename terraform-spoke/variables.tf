# Spoke 프로젝트 변수
variable "spoke_project_name" {
  type        = string
  description = "Spoke 프로젝트 이름"
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
  description = "애플리케이션 서브넷 주소 공간"
}

variable "db_subnet_prefix" {
  type        = string
  description = "데이터베이스 서브넷 주소 공간"
}

variable "aks_subnet_prefix" {
  type        = string
  description = "AKS 서브넷 주소 공간"
}

variable "endpoints_subnet_prefix" {
  type        = string
  description = "Private Endpoints 서브넷 주소 공간"
}

variable "appgw_subnet_prefix" {
  type        = string
  description = "Application Gateway 서브넷 주소 공간"
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

variable "firewall_private_ip" {
  type        = string
  description = "Firewall private IP"
  default     = null
}

# 기존 변수들... 