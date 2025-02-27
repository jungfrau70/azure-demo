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

variable "subnet_id" {
  type        = string
  description = "데이터베이스 서브넷 ID"
}

variable "vnet_id" {
  type        = string
  description = "VNet ID"
}

variable "admin_username" {
  type        = string
  description = "관리자 사용자 이름"
}

variable "admin_password" {
  type        = string
  description = "관리자 비밀번호"
  sensitive   = true
}

variable "storage_mb" {
  type        = number
  description = "스토리지 크기 (MB)"
  default     = 32768
}

variable "sku_name" {
  type        = string
  description = "SKU 이름"
  default     = "GP_Standard_D2s_v3"
}

variable "tags" {
  type        = map(string)
  description = "리소스 태그"
  default     = {}
}

variable "vnet_name" {
  type        = string
  description = "The name of the virtual network"
} 

variable "subnet_name" {
  type        = string
  description = "The name of the subnet"
} 


variable "subnet_prefix" {
  type        = string
  description = "The prefix of the subnet"
} 
