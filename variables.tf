## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## ---------------------------------------------------------------------------------------------------------------------

variable "function_apps" {
  type = list(object({
    function_name           = string
    dependency_install_path = string
    archive_path            = string
    app_settings            = map(string)
  }))
  description = <<EOT
    List of Azure Function Deployment configurations (which should be in independent source folders).
     - Function Name: The name of the Azure Function which should match:
       - Function App V1: The name of the python file (.py)
       - Function App V2: The name provided to @app.function_name decordator in function_app.py
     - Dependency Install Path: The path where dependencies will be installed.
     - Archive Path: The path to the zip archive containing the function code.
     - App Settings: A map of app settings to be set on the function app.
  EOT
}

variable "function_app_name" {
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
