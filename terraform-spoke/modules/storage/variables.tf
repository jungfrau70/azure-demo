variable "resource_group_name" {
  type        = string
  description = "리소스 그룹 이름"
}

variable "location" {
  type        = string
  description = "Azure 리전"
}

variable "storage_account_name" {
  type        = string
  description = "스토리지 계정 이름"
}

variable "share_name" {
  type        = string
  description = "파일 공유 이름"
}

variable "storage_class_name" {
  type        = string
  description = "Kubernetes 스토리지 클래스 이름"
}

variable "subnet_id" {
  type        = string
  description = "스토리지 계정에 연결할 서브넷 ID"
}

variable "account_tier" {
  type        = string
  description = "스토리지 계정 티어"
  default     = "Standard"
}

variable "replication_type" {
  type        = string
  description = "스토리지 계정 복제 유형"
  default     = "LRS"
}

variable "allowed_subnet_ids" {
  type        = list(string)
  description = "스토리지 계정 접근이 허용된 서브넷 ID 목록"
  default     = []
}

variable "containers" {
  type = map(object({
    access_type = string
  }))
  description = "생성할 컨테이너 목록과 접근 유형"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "리소스에 적용할 태그"
  default     = {}
} 