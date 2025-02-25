variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "환경 구분 (dev, stg, prod 등)"
  type        = string
}

variable "project" {
  description = "프로젝트 이름"
  type        = string
}

variable "default_tags" {
  description = "모든 리소스에 적용될 기본 태그"
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
  type        = string
  description = "스포크 리소스 그룹 이름"
}

variable "location" {
  type        = string
  description = "리소스 배포 위치"
}

variable "vnet_name" {
  type        = string
  description = "스포크 가상 네트워크 이름"
}

variable "address_space" {
  type        = list(string)
  description = "가상 네트워크 주소 공간"
}

variable "dns_servers" {
  type        = list(string)
  description = "DNS 서버 목록"
  default     = []
}

variable "subnets" {
  type = map(object({
    address_prefixes = list(string)
  }))
  description = "서브넷 구성"
}

variable "tags" {
  type        = map(string)
  description = "리소스에 적용할 태그"
  default     = {}
}

# 추가 변수들은 필요에 따라 여기에 정의됩니다 