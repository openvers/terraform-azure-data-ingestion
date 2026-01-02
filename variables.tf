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

variable "dependency_install_path" {
  type        = string
  description = "Source Dependency Install Target Path"
}

variable "archive_path" {
  type        = string
  description = "Zip Archival Path"
}

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## These variables have defaults and may be overridden
## ---------------------------------------------------------------------------------------------------------------------

variable "app_settings" {
  type        = map(any)
  description = "Azure Functions Application App Setting/ Environment Variables"
  default     = {}
}

variable "program_name" {
  type        = string
  description = "Program Name"
  default     = "dp-lessons"
}

variable "project_name" {
  type        = string
  description = "Project name for the data lake"
  default     = "ex-data-lake"
}
