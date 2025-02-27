terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.20.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 리소스 그룹 생성
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
} 