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

locals {
  app_settings = merge(var.app_settings, {
    WEBSITE_RUN_FROM_PACKAGE = module.function_source.function_zip_blob_url
  })
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
  container_name             = var.function_container_name
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
## FUNCTION SOURCE MODULE
##
## This module will archive the Azure Functions source code, create an ADLS Bucket to store the Azure Function
## source code, and configure access to a specific AD group.
##
## Parameters:
## - `resource_group_name`: Azure Resource Group name.
## - `resource_group_location`: Azure Resource Group location.
## - `security_group_id`: Azure AD Security Group to allow access.
## ---------------------------------------------------------------------------------------------------------------------
module "function_source" {
  source = "../azure_functions_zip"

  function_bucket_name       = module.function_bucket.bucket_name
  function_container_name    = module.function_bucket.bucket_container_name
  function_bucket_connection = module.function_bucket.bucket_connection
  resource_group_name        = data.azurerm_resource_group.this.name
  security_group_id          = var.security_group_id
  dependency_install_path    = var.dependency_install_path
  archive_path               = var.archive_path

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
## AZURERM LINUX FUNCTION APP RESOURCE
##
## Create the ELT function to convert data in the Raw Bucket to
## Parquet Format in the Standard Bucket, and configure with Application Insights
## and ENV Variables required by functions. Use a function blob zip
## to deploy all functions instead of creating individual functions
## with azurerm_function_app_function - too many problems
##
##  Need to compile requirements.txt prior to deploying with Terraform.
##  Azure Functions with Linux os_type doesn't support installing requirements.txt
##  https://stackoverflow.com/questions/62903172/functionapp-not-importing-python-module
##
##  Python also isn't a valid runtime for Windows os_type function apps
##  https://stackoverflow.com/questions/67750337/python-projects-are-not-supported-on-windows-function-app-deploy-to-a-linux-fun
##
##  App Settings
##  https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings
##
## Parameters:
## - `name`: Azure Functions application name.
## - `resource_grioup_name`: Azure Resource Group name.
## - `location`: Azure Resource Group location.
## - `service_plan_id`: Azure Functions Service Plan ID.
## - `storage_account_name`: ADLS trigger bucket name.
## - `storage_account_access_key`: ADLS trigger bucket access key.
## - `application_insights_connection_string`: Azure Applications Insights connection string.
## - `application_insights_key`: Azure Applications Insights key.
## - `python_version`: Azure Functions Application Runtime enviornment (python version).
## - `app_settings`: Azure Functions Application app settings/ Environment Variables.
## ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_linux_function_app" "this" {
  provider = azurerm.auth_session

  name                = var.function_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location
  service_plan_id     = azurerm_service_plan.this.id

  storage_account_name       = module.function_bucket.bucket_name
  storage_account_access_key = module.function_bucket.bucket_key

  site_config {
    application_insights_connection_string = azurerm_application_insights.this.connection_string
    application_insights_key               = azurerm_application_insights.this.instrumentation_key

    application_stack {
      python_version = var.python_version
    }
  }

  app_settings = local.app_settings
}
