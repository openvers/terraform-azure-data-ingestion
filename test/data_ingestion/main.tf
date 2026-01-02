terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "sim-parables"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "ci-cd-azure-workspace"
    }
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## RANDOM STRING RESOURCE
##
## This resource generates a random string of a specified length.
##
## Parameters:
## - `special`: Whether to include special characters in the random string.
## - `upper`: Whether to include uppercase letters in the random string.
## - `length`: The length of the random string.
## ---------------------------------------------------------------------------------------------------------------------
resource "random_string" "this" {
  special = false
  upper   = false
  length  = 4
}

locals {
  suffix = "test-${random_string.this.result}"
}

provider "azurerm" {
  features {}
}

##---------------------------------------------------------------------------------------------------------------------
## AZURERM PROVIDER
##
## Azure Resource Manager (Azurerm) provider authenticated with service account client credentials.
##
## Parameters:
## - `client_id`: Service account client ID.
## - `client_secret`: Service account client secret.
## - `subscription_id`: Azure subscription ID.
## - `tenant_id`: Azure tenant ID.
## - `prevent_deletion_if_contains_resources`: Disable resource loss prevention mechanism.
##---------------------------------------------------------------------------------------------------------------------
provider "azurerm" {
  alias = "auth_session"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

##---------------------------------------------------------------------------------------------------------------------
## AZURERM RESOURCE GROUP RESOURCE
##
## Create an Azure Resource Group to organize/group collections of resources, and isolate for billing.
##
## Parameters:
## - `name`: Azure Resource Group name.
## - `location`: Azure resource group location.
##---------------------------------------------------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  provider = azurerm.auth_session

  name     = "${local.suffix}-resource-group"
  location = var.azure_region
}

## ---------------------------------------------------------------------------------------------------------------------
## DATA LAKE MODULE
##
## Provisions a complete Azure Data Lake environment, including Blob Storage containers for bronze, silver, and gold medallion data layers,
## IAM roles and policies, encryption, function integration, and supporting resources.
##
## Parameters:
## - `bronze_bucket_name`: Name of the ADLS Storage container for raw/bronze data.
## - `silver_bucket_name`: Name of the ADLS Storage container for processed/silver data.
## - `gold_bucket_name`: Name of the ADLS Storage container for curated/gold data.
##
## Notes:
## - This module is designed for end-to-end data lake testing and development.
## - Additional configuration may be required for Azure Function integration and IAM roles depending on your use case.
## ---------------------------------------------------------------------------------------------------------------------
module "data_lake" {
  source = "github.com/openvers/terraform-azure-data-lake.git?ref=1437474e21ebf06ed49f3a3354ec6eb2f922163e"

  bronze_bucket_name  = "${local.suffix}-bronze"
  silver_bucket_name  = "${local.suffix}-silver"
  gold_bucket_name    = "${local.suffix}-gold"
  key_vault_name      = "${replace(local.suffix, " ", "-")}-datalake-akv"
  security_group_id   = var.SECURITY_GROUP_ID
  resource_group_name = azurerm_resource_group.this.name

  providers = {
    azurerm.auth_session = azurerm.auth_session
  }
}


##---------------------------------------------------------------------------------------------------------------------
## AZURE FUNCTION APPLICATION MODULE
##
## This module provisions an Azure Functions Service Plan and Application configured to execute on a http trigger.
## This Function Application is also configured to log to Azure Applications Insights for debug purposes.
##
## Parameters:
## - `function_name`: Azure Function Application name.
## - `trigger_bucket_name`: ADLS trigger bucket name.
## - `trigger_bucket_access_key`: ADLS trigger bucket shared access key.
## - `resource_group_name`: Azure Resource Group name.
## - `resource_group_location`: Azure Resource Group location.
## - `app_settings`: Map of Azure Functions environment variables.
##---------------------------------------------------------------------------------------------------------------------
module "azure_function_application" {
  source = "../../"

  function_name           = "${var.function_name}-http-${local.suffix}"
  function_bucket_name    = "${var.function_name}-${local.suffix}-adls"
  dependency_install_path = "./source"
  archive_path            = "./source/function.zip"
  resource_group_name     = azurerm_resource_group.this.name
  security_group_id       = var.SECURITY_GROUP_ID
  key_vault_id            = module.data_lake.azure_key_vault_id
  key_name                = module.data_lake.azure_key_vault_key

  app_settings = {
    OUTPUT_BUCKET_NAME = module.data_lake.bronze_bucket_name
    OUTPUT_BUCKET_KEY  = module.data_lake.bronze_bucket_key
  }

  providers = {
    azurerm.auth_session = azurerm.auth_session
  }
}
