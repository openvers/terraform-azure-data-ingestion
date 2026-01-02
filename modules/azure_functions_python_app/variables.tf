## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## ---------------------------------------------------------------------------------------------------------------------

variable "function_name" {
  type        = string
  description = "Azure Function App Name"
}

variable "function_bucket_name" {
  type        = string
  description = "Azure Function Storage Account Bucket Name"
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

variable "key_name" {
  type        = string
  description = "The name of the Key Vault Key to use for customer-managed encryption."
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

variable "service_plan_name" {
  type        = string
  description = "Azure Service Plan Name"
  default     = "example-function-service-plan"
}

variable "service_plan_os_type" {
  type        = string
  description = "Azure Service Plan OS Type"
  default     = "Linux"
}

variable "service_plan_sku_type" {
  type        = string
  description = "Azure Service Plan SKU Type"
  default     = "B1"
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
