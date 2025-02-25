output "application_gateway_id" {
  value       = azurerm_application_gateway.appgw.id
  description = "Application Gateway ID"
}

output "application_gateway_name" {
  value       = azurerm_application_gateway.appgw.name
  description = "Application Gateway 이름"
}

output "public_ip_address" {
  value       = azurerm_public_ip.appgw.ip_address
  description = "Application Gateway 공용 IP 주소"
} 