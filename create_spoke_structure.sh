#!/bin/bash

# 기본 디렉토리 구조 생성
mkdir -p terraform-spoke/modules/{spoke-network,aks,appgateway,application}
mkdir -p terraform-spoke/environments/dev

# 모듈별 provider 설정
cat > terraform-spoke/modules/application/main.tf << EOF
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}
EOF

cat > terraform-spoke/modules/aks/main.tf << EOF
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}
EOF

# 기타 모듈 파일 생성
for module in spoke-network appgateway; do
    for file in main.tf variables.tf outputs.tf; do
        touch "terraform-spoke/modules/$module/$file"
    done
done

# 환경 설정 파일 생성
mkdir -p terraform-spoke/environments/dev
cat > terraform-spoke/environments/dev/variables.tf << EOF
variable "project_name" {
  type        = string
  description = "프로젝트 이름"
}

variable "location" {
  type        = string
  description = "Azure 리전"
}

variable "spoke_rg" {
  type        = string
  description = "Spoke 리소스 그룹 이름"
}

variable "github_token" {
  type        = string
  description = "GitHub Personal Access Token"
  sensitive   = true
}

variable "github_repo" {
  type        = string
  description = "GitHub 레포지토리 이름"
}

variable "github_owner" {
  type        = string
  description = "GitHub 계정 이름"
}
EOF

# backend.hcl은 setup_terraform.sh에서 생성됨

echo "Spoke 프로젝트 구조가 생성되었습니다." 