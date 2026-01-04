output "function_default_hostname" {
  description = "Azure Function Default Hostname"
  value       = azurerm_linux_function_app.this.default_hostname
}

output "function_api_endpoint" {
  description = "Azure Function Application API Endpoint"
  value       = "${azurerm_linux_function_app.this.default_hostname}/api/${var.function_name}"
}

output "function_default_x_key" {
  description = "Azure Function Default X-Key"
  value       = data.azurerm_function_app_host_keys.this.default_function_key
  sensitive   = true
}

output "function_primary_x_key" {
  description = "Azure Function Primary X-Key"
  value       = data.azurerm_function_app_host_keys.this.primary_key
  sensitive   = true
}

output "function_verification_id" {
  description = "Custom Domain Verification ID. The identifier used by App Service to perform domain ownership verification via DNS TXT record."
  value       = azurerm_linux_function_app.this.custom_domain_verification_id
  sensitive   = true
}

output "function_managed_identity" {
  description = "Azure Function Managed Identity"
  value       = azurerm_linux_function_app.this.identity
}

output "function_site_credentials" {
  description = "Azure Function Site Credentials User"
  value       = azurerm_linux_function_app.this.site_credential
  sensitive   = true
}
