output "bronze_bucket_name" {
  description = "ADLS Bucket Name for Bronze Data"
  value       = module.data_lake.bronze_bucket_name
}

output "bronze_bucket_container_name" {
  description = "ADLS Bucket Container Name for Bronze Data"
  value       = module.data_lake.bronze_bucket_container_name
}

output "bronze_bucket_key" {
  description = "ADLS Bucket Shared Access Key for Bronze Data"
  value       = nonsensitive(module.data_lake.bronze_bucket_key)
}

output "silver_bucket_name" {
  description = "ADLS Bucket Name for Silver Data"
  value       = module.data_lake.silver_bucket_name
}

output "silver_bucket_container_name" {
  description = "ADLS Bucket Container Name for Silver Data"
  value       = module.data_lake.silver_bucket_container_name
}

output "silver_bucket_key" {
  description = "ADLS Bucket Shared Access Key for Silver Data"
  value       = nonsensitive(module.data_lake.silver_bucket_key)
}

output "gold_bucket_name" {
  description = "ADLS Bucket Name for Gold Data"
  value       = module.data_lake.gold_bucket_name
}

output "gold_bucket_container_name" {
  description = "ADLS Bucket Container Name for Gold Data"
  value       = module.data_lake.gold_bucket_container_name
}

output "gold_bucket_key" {
  description = "ADLS Bucket Shared Access Key for Gold Data"
  value       = nonsensitive(module.data_lake.gold_bucket_key)
}

output "function_default_hostname" {
  description = "Azure Function Default Hostname"
  value       = module.azure_function_application.function_default_hostname["main"]
}

output "function_api_endpoint" {
  description = "Azure Function Application API Endpoint"
  value       = module.azure_function_application.function_api_endpoint["main"]
}

output "function_default_x_key" {
  description = "Azure Function Default X-Key"
  value       = module.azure_function_application.function_default_x_key["main"]
  sensitive   = true
}

output "function_primary_x_key" {
  description = "Azure Function Primary X-Key"
  value       = module.azure_function_application.function_primary_x_key["main"]
  sensitive   = true
}

output "function_verification_id" {
  description = "Custom Domain Verification ID. The identifier used by App Service to perform domain ownership verification via DNS TXT record."
  value       = module.azure_function_application.function_verification_id["main"]
  sensitive   = true
}

output "function_managed_identity" {
  description = "Azure Function Managed Identity"
  value       = module.azure_function_application.function_managed_identity["main"]
}

output "function_site_credentials" {
  description = "Azure Function Site Credentials User"
  value       = module.azure_function_application.function_site_credentials["main"]
  sensitive   = true
}
