## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## ---------------------------------------------------------------------------------------------------------------------

variable "function_app_name" {
  type        = string
  description = "Azure Function App Name"
}

variable "function_name" {
  type        = string
  description = "Azure Function Name. This must match the folder name containing the function code."
}

variable "function_bucket_name" {
  type        = string
  description = "Azure Function Storage Account Bucket Name"
}

variable "function_bucket_container_name" {
  type        = string
  description = "Azure Function Storage Account Container Name"
}

variable "function_bucket_connection" {
  type        = string
  description = "Azure Function Storage Account Connection String"
}

variable "function_bucket_key" {
  type        = string
  description = "Azure Function Storage Account Key"
}

variable "resource_group_name" {
  type        = string
  description = "Azure Resouce Group Name"
}

variable "security_group_id" {
  type        = string
  description = "Microsoft Entra Security Group ID"
}

variable "key_vault_id" {
  type        = string
  description = "The ID of the Key Vault to use for customer-managed encryption."
}

variable "app_service_plan_id" {
  type        = string
  description = "Azure Service App Plan ID"
}

variable "key_name" {
  type        = string
  description = "The name of the Key Vault Key to use for customer-managed encryption."
}

variable "application_insights_connection_string" {
  type        = string
  description = "The connection string for the Application Insights instance."
}

variable "application_insights_key" {
  type        = string
  description = "The key for the Application Insights instance."
}

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## These variables have defaults and may be overridden
## ---------------------------------------------------------------------------------------------------------------------

variable "python_version" {
  type        = string
  description = "Azure Function Runtime Python Version"
  default     = "3.10"
}

variable "function_always_on" {
  type        = bool
  description = "Azure Function Always On"
  default     = true
}

variable "function_container_name" {
  type        = string
  description = "Azure Function Storage Account Bucket Container Name"
  default     = "source"
}

variable "app_settings" {
  type        = map(any)
  description = "Azure Functions Application App Setting/ Environment Variables"
  default     = {}
}

variable "dependency_install_path" {
  type        = string
  description = "Source Dependency Install Target Path"
  default     = "./source"
}

variable "archive_path" {
  type        = string
  description = "Zip Archival Path"
  default     = "./source/function.zip"
}
