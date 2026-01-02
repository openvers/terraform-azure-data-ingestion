output "bronze_bucket_name" {
  description = "ADLS Bucket Name for Bronze Data"
  value       = module.data_lake.bronze_bucket_name
}

output "bronze_bucket_key" {
  description = "ADLS Bucket Shared Access Key for Bronze Data"
  value       = nonsensitive(module.data_lake.bronze_bucket_key)
}

output "silver_bucket_name" {
  description = "ADLS Bucket Name for Silver Data"
  value       = module.data_lake.silver_bucket_name
}

output "silver_bucket_key" {
  description = "ADLS Bucket Shared Access Key for Silver Data"
  value       = nonsensitive(module.data_lake.silver_bucket_key)
}

output "gold_bucket_name" {
  description = "ADLS Bucket Name for Gold Data"
  value       = module.data_lake.gold_bucket_name
}

output "gold_bucket_key" {
  description = "ADLS Bucket Shared Access Key for Gold Data"
  value       = nonsensitive(module.data_lake.gold_bucket_key)
}

output "function_url" {
  description = "Azure Function Application URL"
  value       = module.azure_function_application.function_url
}
