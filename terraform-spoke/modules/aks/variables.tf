variable "cluster_name" {
  type        = string
  description = "AKS 클러스터 이름"
}

variable "resource_group_name" {
  type        = string
  description = "리소스 그룹 이름"
}

variable "location" {
  type        = string
  description = "Azure 리전"
}

variable "dns_prefix" {
  type        = string
  description = "AKS DNS 접두사"
  default     = "aks"
}

variable "kubernetes_version" {
  description = "AKS 클러스터의 Kubernetes 버전"
  type        = string
  default     = "1.30.9" # LTS 지원 버전으로 업데이트
}

variable "sku_tier" {
  description = "AKS 클러스터의 SKU 티어 (Free, Standard, Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "허용되는 값: Free, Standard, Premium"
  }
}

variable "aks_identity_name" {
  type        = string
  description = "AKS Managed Identity 이름"
}

variable "aks_node_size" {
  type        = string
  description = "AKS 노드 VM 크기"
  default     = "Standard_D2s_v3"
}

# az network private-endpoint list --resource-group rg-spoke-dev -o table
variable "default_node_pool" {
  type = object({
    name      = string
    vm_size   = string
    min_count = number
    max_count = number
  })
  description = "기본 노드풀 설정"
  default = {
    name      = "default"
    vm_size   = "Standard_D2s_v3"  # 기본값 설정
    min_count = 3
    max_count = 5
  }
}

variable "subnet_id" {
  type        = string
  description = "AKS 서브넷 ID"
}

variable "tags" {
  type        = map(string)
  description = "리소스 태그"
  default     = {}
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID"
  default     = null # OMS agent를 선택적으로 만들기 위해
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for AKS nodes"
}

variable "cluster_config" {
  description = "AKS 클러스터 설정"
  type = object({
    private_cluster_enabled = bool
    api_server_authorized_ip_ranges = list(string)
    network_plugin = string
    network_policy = string
    service_cidr = string
    dns_service_ip = string
  })
}
