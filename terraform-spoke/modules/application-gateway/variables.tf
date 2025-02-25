variable "resource_group_name" {
  type        = string
  description = "리소스 그룹 이름"
}

variable "location" {
  type        = string
  description = "Azure 리전"
}

variable "project_name" {
  type        = string
  description = "프로젝트 이름"
}

variable "gateway_public_ip_name" {
  type        = string
  description = "Application Gateway 공용 IP 이름"
}

variable "gateway_name" {
  type        = string
  description = "Application Gateway 이름"
}

variable "gateway_subnet_id" {
  type        = string
  description = "게이트웨이 서브넷 ID"
}

variable "gateway_sku" {
  type        = string
  default     = "VpnGw1"
  description = "게이트웨이 SKU"
}

variable "enable_bgp" {
  type        = bool
  default     = false
  description = "BGP 활성화 여부"
}

variable "tags" {
  type        = map(string)
  description = "리소스 태그"
  default     = {}
}

variable "appgw_subnet_id" {
  type        = string
  description = "Application Gateway 서브넷 ID"
}

variable "enable_waf" {
  type        = bool
  description = "WAF 정책 활성화 여부"
  default     = false
} 