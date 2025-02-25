variable "prefix" {
  type        = string
  description = "리소스 이름 접두사"
}

variable "resource_group_name" {
  type        = string
  description = "리소스 그룹 이름"
}

variable "location" {
  type        = string
  description = "Azure 리전"
}

variable "environment" {
  type        = string
  description = "환경 (dev, prod 등)"
}

variable "project_name" {
  type        = string
  description = "프로젝트 이름"
}

variable "hub_rg" {
  type        = string
  description = "Hub 리소스 그룹 이름"
}

variable "bastion_nsg_name" {
  type        = string
  description = "Bastion NSG 이름"
}

variable "jumpbox_nsg_name" {
  type        = string
  description = "Jumpbox NSG 이름"
}

variable "bastion_subnet_id" {
  type        = string
  description = "Bastion 서브넷 ID"
}

variable "jumpbox_subnet_id" {
  type        = string
  description = "Jumpbox 서브넷 ID"
}

variable "fw_subnet_id" {
  type        = string
  description = "Firewall 서브넷 ID"
}

variable "tags" {
  type        = map(string)
  description = "리소스에 적용할 태그"
  default     = {}
} 