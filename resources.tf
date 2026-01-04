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

data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

## ---------------------------------------------------------------------------------------------------------------------
## FUNCTION BUCKET MODULE
##
## This module will create an ADLS Bucket to store the Azure Function source code, and configure access to a specific
## AD group.
##
## Parameters:
## - `bucket_name`: ADLS bucket name.
## - `container_name`: ADLS container name.
## - `resource_group_name`: Azure Resource Group name.
## - `resource_group_location`: Azure Resource Group location.
## - `security_group_id`: Azure AD Security Group to allow access.
## ---------------------------------------------------------------------------------------------------------------------
module "function_bucket" {
  source = "github.com/openvers/terraform-azure-data-lake.git//modules/adls_bucket?ref=0bfe41e34f3effcb40d361792b50fa2e77a0d5de"

  bucket_name                = var.function_bucket_name
  container_name             = "source"
  azure_storage_account_kind = "BlockBlobStorage"
  resource_group_name        = data.azurerm_resource_group.this.name
  security_group_id          = var.security_group_id
  key_vault_id               = var.key_vault_id
  key_name                   = var.key_name

  providers = {
    azurerm.auth_session = azurerm.auth_session
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## AZURERM SERVICE PLAN RESOURCE
##
## Configure a Service Plan for Function App Specs
## and Performance.
##
## Note: Free Tier is no longer an option.
##
## Parameters:
## - `name`: Azure Functions Service Plan name.
## - `resource_grioup_name`: Azure Resource Group name.
## - `location`: Azure Resource Group location.
## - `os_type`: Azure Functions Operating System.
## - `sku_name`: Azure Functions sku type.
## ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_service_plan" "this" {
  provider = azurerm.auth_session

  name                = var.service_plan_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  os_type             = var.service_plan_os_type
  sku_name            = var.service_plan_sku_type
}


## ---------------------------------------------------------------------------------------------------------------------
## AZURERM APPLICATION INSIGHTS RESOURCE
##
## Configure Application Insights to monitor Function executions and logs. Not configured by default.
##
## Parameters:
## - `name`: Azure Application Insights name.
## - `resource_grioup_name`: Azure Resource Group name.
## - `location`: Azure Resource Group location.
## - `application_type`: Azure Application Insights type.
## ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_application_insights" "this" {
  provider = azurerm.auth_session

  name                = "${var.service_plan_name}-app-insights"
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  application_type    = "other"
}


## ---------------------------------------------------------------------------------------------------------------------
## AZURE FUNCTIONS PYTHON APP MODULE
##
## This module provisions an Azure Functions Python App for processing data.
##
## Parameters:
## - `function_app_name`: Azure Function name.
## - `function_bucket_name`: Azure Storage Bucket name.
## - `resource_group_name`: Azure Resource Group name.
## - `security_group_id`: Azure Security Group ID.
## - `dependency_install_path`: Path to install dependencies.
## - `archive_path`: Path to the archive file.
## ---------------------------------------------------------------------------------------------------------------------
module "azure_functions_python_app" {
  source   = "./modules/azure_functions_python_app"
  for_each = { for f in var.function_apps : f.function_name => f }

  function_app_name                      = var.function_app_name
  function_name                          = each.value.function_name
  function_bucket_name                   = module.function_bucket.bucket_name
  function_bucket_container_name         = module.function_bucket.bucket_container_name
  function_bucket_connection             = module.function_bucket.bucket_connection
  function_bucket_key                    = module.function_bucket.bucket_key
  app_service_plan_id                    = azurerm_service_plan.this.id
  application_insights_connection_string = azurerm_application_insights.this.connection_string
  application_insights_key               = azurerm_application_insights.this.instrumentation_key
  resource_group_name                    = var.resource_group_name
  security_group_id                      = var.security_group_id
  key_vault_id                           = var.key_vault_id
  key_name                               = var.key_name
  dependency_install_path                = each.value.dependency_install_path
  archive_path                           = each.value.archive_path
  app_settings                           = each.value.app_settings

  providers = {
    azurerm.auth_session = azurerm.auth_session
  }
}
