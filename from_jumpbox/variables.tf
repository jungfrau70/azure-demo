variable "resource_group_name" {
  type        = string
  description = "리소스 그룹 이름"
}

variable "location" {
  type        = string
  description = "Azure 리전"
  default     = "koreacentral"
}

variable "environment" {
  type        = string
  description = "환경 (dev, prod 등)"
  default     = "dev"
}

variable "tags" {
  type        = map(string)
  description = "리소스에 적용할 태그"
  default     = {}
}

variable "jumpbox_password" {
  type        = string
  description = "Jumpbox VM 관리자 비밀번호"
  sensitive   = true
}

variable "tenant_id" {
  type        = string
  description = "Azure AD 테넌트 ID"
}

variable "subscription_id" {
  type        = string
  description = "Azure 구독 ID"
} 