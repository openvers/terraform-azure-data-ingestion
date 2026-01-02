terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      configuration_aliases = [
        azurerm.auth_session,
      ]
    }
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## AZURE FUNCTIONS PYTHON APP MODULE
##
## This module provisions an Azure Functions Python App for processing data.
##
## Parameters:
## - `function_name`: Azure Function name.
## - `function_bucket_name`: Azure Storage Bucket name.
## - `resource_group_name`: Azure Resource Group name.
## - `security_group_id`: Azure Security Group ID.
## - `dependency_install_path`: Path to install dependencies.
## - `archive_path`: Path to the archive file.
## ---------------------------------------------------------------------------------------------------------------------
module "azure_functions_python_app" {
  source = "./modules/azure_functions_python_app"

  function_name           = var.function_name
  function_bucket_name    = var.function_bucket_name
  resource_group_name     = var.resource_group_name
  security_group_id       = var.security_group_id
  key_vault_id            = var.key_vault_id
  key_name                = var.key_name
  dependency_install_path = var.dependency_install_path
  archive_path            = var.archive_path

  providers = {
    azurerm.auth_session = azurerm.auth_session
  }
}
