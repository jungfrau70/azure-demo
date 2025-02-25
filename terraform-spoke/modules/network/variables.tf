variable "environment" {
  type        = string
  description = "환경 (dev, prod 등)"
}

variable "project_name" {
  type        = string
  description = "프로젝트 이름"
}

variable "location" {
  type        = string
  description = "Azure 리전"
}

variable "resource_group_name" {
  type        = string
  description = "리소스 그룹 이름"
}

variable "vnet_name" {
  type        = string
  description = "VNet 이름"
  default     = null
}

variable "address_space" {
  type        = list(string)
  description = "VNet 주소 공간"
  default     = []
}

variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name    = string
      service_delegation = list(object({
        name    = string
        actions = list(string)
      }))
    }), null)
  }))
  description = "서브넷 구성"
  default = {
    aks = {
      name             = "snet-aks"
      address_prefixes = ["10.2.0.0/22"]
      service_endpoints = []
    }
    app = {
      name             = "snet-app"
      address_prefixes = ["10.2.4.0/24"]
      service_endpoints = []
    }
    db = {
      name             = "snet-db"
      address_prefixes = ["10.2.5.0/24"]
      service_endpoints = []
    }
    endpoints = {
      name             = "snet-endpoints"
      address_prefixes = ["10.2.6.0/24"]
      service_endpoints = []
    }
    gateway = {
      name             = "GatewaySubnet"
      address_prefixes = ["10.2.7.0/24"]
      service_endpoints = []
    }
  }
}

variable "nsg_rules" {
  type = map(object({
    priority               = number
    direction             = string
    access                = string
    protocol              = string
    source_port_range     = string
    destination_port_range = string
    source_address_prefix = string
    destination_address_prefix = string
  }))
  description = "네트워크 보안 그룹 규칙"
  default     = {}
}

variable "dns_servers" {
  type        = list(string)
  description = "사용자 지정 DNS 서버"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "리소스에 적용할 태그"
  default     = {}
}

variable "app_subnet_prefix" {
  type        = string
  description = "애플리케이션 서브넷 주소 공간"
}

variable "db_subnet_prefix" {
  type        = string
  description = "데이터베이스 서브넷 주소 공간"
}

variable "endpoints_subnet_prefix" {
  type        = string
  description = "엔드포인트 서브넷 주소 공간"
}

variable "loadbalancer_subnet_prefix" {
  type        = string
  description = "로드밸런서 서브넷 주소 공간"
}

variable "spoke_vnet_name" {
  type        = string
  description = "Spoke VNet 이름"
}

variable "spoke_rg" {
  type        = string
  description = "Spoke 리소스 그룹 이름"
}

variable "spoke_vnet_prefix" {
  type        = string
  description = "Spoke VNet 주소 공간"
}

variable "hub_resource_group_name" {
  type        = string
  description = "Hub VNet이 있는 리소스 그룹 이름"
}

# Hub VNet 피어링 설정
variable "enable_hub_peering" {
  type        = bool
  description = "Hub VNet과의 피어링 활성화 여부"
  default     = false
}

variable "hub_vnet_id" {
  type        = string
  description = "Hub VNet ID"
  default     = null
}

variable "hub_vnet_name" {
  type        = string
  description = "Hub VNet 이름"
  default     = null
}

variable "firewall_private_ip" {
  description = "Hub Firewall의 프라이빗 IP 주소"
  type        = string
} 