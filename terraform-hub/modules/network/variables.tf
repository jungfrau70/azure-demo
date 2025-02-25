variable "location" {
  type        = string
  description = "리소스 위치"
}

variable "hub_rg" {
  type        = string
  description = "Hub 리소스 그룹 이름"
}

variable "environment" {
  type        = string
  description = "환경 (dev, prod 등)"
}

variable "project_name" {
  type        = string
  description = "프로젝트 이름"
}

variable "hub_vnet_name" {
  type        = string
  description = "Hub VNet 이름"
}

variable "hub_vnet_prefix" {
  type        = string
  description = "Hub VNet 주소 공간"
}

variable "fw_subnet_prefix" {
  type        = string
  description = "Firewall 서브넷 주소 공간"
}

variable "bastion_subnet_prefix" {
  type        = string
  description = "Bastion 서브넷 주소 공간"
}

variable "jumpbox_subnet_prefix" {
  type        = string
  description = "Jumpbox 서브넷 주소 공간"
}

variable "fw_name" {
  type        = string
  description = "Firewall 이름"
}

variable "resource_group_name" {
  type        = string
  description = "리소스 그룹 이름"
}

variable "vnet_name" {
  type        = string
  description = "VNet 이름"
}

variable "address_space" {
  type        = list(string)
  description = "VNet 주소 공간"
}

variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  description = "서브넷 구성"
}

variable "tags" {
  type        = map(string)
  description = "리소스 태그"
  default     = {}
}

variable "prefix" {
  type        = string
  description = "리소스 이름에 사용할 접두사"
  default     = "hub"  # 또는 적절한 기본값 설정
} 