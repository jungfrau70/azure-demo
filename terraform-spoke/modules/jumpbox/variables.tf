variable "environment" {
  type        = string
  description = "Environment name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "jumpbox_subnet_id" {
  type        = string
  description = "Subnet ID for jumpbox VM"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the jumpbox VM"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for the jumpbox VM"
} 