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

variable "log_analytics_retention_days" {
  type        = number
  description = "로그 보존 기간(일)"
  default     = 30
}

variable "monitor_action_group_name" {
  type        = string
  description = "모니터링 액션 그룹 이름"
}

variable "monitor_email_receivers" {
  type = list(object({
    name                    = string
    email_address          = string
    use_common_alert_schema = bool
  }))
  description = "알림을 받을 이메일 수신자 목록"
}

variable "alert_scopes" {
  type        = list(string)
  description = "알림을 설정할 리소스 ID 목록"
}

variable "vnet_id" {
  description = "The ID of the Hub Virtual Network for monitoring"
  type        = string
} 