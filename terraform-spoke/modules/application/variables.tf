variable "environment" {
  type        = string
  description = "환경 (dev, prod 등)"
}

variable "location" {
  type        = string
  description = "Azure 리전"
}

variable "resource_group_name" {
  type        = string
  description = "리소스 그룹 이름"
}

variable "applications" {
  type = map(object({
    app_settings = map(string)
  }))
  description = "배포할 애플리케이션 설정"
  default     = {}
}

variable "acr_login_server" {
  type        = string
  description = "Azure Container Registry 로그인 서버"
}

variable "acr_username" {
  type        = string
  description = "ACR 사용자 이름"
  default     = ""
}

variable "acr_password" {
  type        = string
  description = "ACR 비밀번호"
  default     = ""
  sensitive   = true
}

variable "docker_image_name" {
  type        = string
  description = "도커 이미지 이름"
}

variable "app_version" {
  type        = string
  description = "애플리케이션 버전"
}

variable "keyvault_name" {
  type        = string
  description = "Key Vault 이름"
}

variable "tags" {
  type        = map(string)
  description = "리소스에 적용할 태그"
  default     = {}
}

variable "github_repo" {
  type = string
}

variable "helm_values" {
  type = object({
    replicaCount = number
    ingress = object({
      enabled = bool
      host    = string
    })
  })
  description = "Helm 차트 값"
}

variable "db_connection_string" {
  type        = string
  description = "데이터베이스 연결 문자열"
  default     = ""  # 데이터베이스가 없는 경우를 위한 기본값
} 