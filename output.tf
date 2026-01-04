output "function_default_hostname" {
  description = "Azure Function Default Hostname"
  value = {
    for function_name, mod in module.azure_functions_python_app : function_name => mod.function_default_hostname
  }
}

output "function_api_endpoint" {
  description = "Azure Function Application API Endpoint"
  value = {
    for function_name, mod in module.azure_functions_python_app : function_name => mod.function_api_endpoint
  }
}

output "function_default_x_key" {
  description = "Azure Function Default X-Key"
  value = {
    for function_name, mod in module.azure_functions_python_app : function_name => mod.function_default_x_key
  }
  sensitive = true
}

output "function_primary_x_key" {
  description = "Azure Function Primary X-Key"
  value = {
    for function_name, mod in module.azure_functions_python_app : function_name => mod.function_primary_x_key
  }
  sensitive = true
}

output "function_verification_id" {
  description = "Custom Domain Verification ID. The identifier used by App Service to perform domain ownership verification via DNS TXT record."
  value = {
    for function_name, mod in module.azure_functions_python_app : function_name => mod.function_verification_id
  }
  sensitive = true
}

output "function_managed_identity" {
  description = "Azure Function Managed Identity"
  value = {
    for function_name, mod in module.azure_functions_python_app : function_name => mod.function_managed_identity
  }
}

output "function_site_credentials" {
  description = "Azure Function Site Credentials"
  value = {
    for function_name, mod in module.azure_functions_python_app : function_name => mod.function_site_credentials
  }
  sensitive = true
}
