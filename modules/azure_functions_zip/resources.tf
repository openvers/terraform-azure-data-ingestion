/* Azure Function Package

Zip all Azure functions in Source Directory to deployas Zip Package

# Zip Deployment guide
https://learn.microsoft.com/en-us/azure/azure-functions/functions-reference-python?tabs=asgi%2Capplication-level&pivots=python-mode-configuration#folder-structure
*/
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
## NULL RESOURCE
##
## Install the Python dependency with Pip
## ---------------------------------------------------------------------------------------------------------------------
resource "null_resource" "this" {
  provisioner "local-exec" {
    command = <<EOF
    docker run --rm \
      -v "${var.dependency_install_path}/":/app \
      mcr.microsoft.com/azure-functions/python:4-python3.10 \
      bash -c "
        pip install --upgrade pip &&
        pip install -r /app/requirements.txt \
          --target /app/.python_packages/lib/site-packages
      "
    EOF
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## ARCHIVE FILE DATA SOURCE
##
## Zip the Python package for upload to AWS Storage Bucket.
## https://docs.aws.amazon.com/lambda/latest/dg/python-package.html
## https://docs.aws.amazon.com/lambda/latest/dg/packaging-layers.html
##
## Parameters:
## - `type`: Archive file type.
## - `source_dir`: Dependency package path.
## - `output_file_mode`: Unix permission.
## - `output_path`: Archive output path.
## - `excludes`: List of excluded paths to be archived.
## ---------------------------------------------------------------------------------------------------------------------
data "archive_file" "this" {
  depends_on = [null_resource.this]

  type             = "zip"
  output_file_mode = "0666"
  excludes         = [".venv", "function.zip"]
  source_dir       = var.dependency_install_path
  output_path      = var.archive_path
}


## ---------------------------------------------------------------------------------------------------------------------
## AZURE STORAGE BLOB RESOURCE
##
## Upload the Zip package to Functions Bucket.
##
## Parameters:
## - `type`: Blob storage type.
## - `name`: Blob name.
## - `storage_account_name`: Azure ADLS bucket name.
## - `storage_container_name`: Azure ADLS container name.
## - `source`: File path to function archive source file.
## ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_storage_blob" "this" {
  provider   = azurerm.auth_session
  depends_on = [data.archive_file.this]

  type                   = "Block"
  name                   = reverse(split("/", var.archive_path))[0]
  storage_account_name   = var.function_bucket_name
  storage_container_name = var.function_container_name
  source                 = var.archive_path
}


## ---------------------------------------------------------------------------------------------------------------------
## AZURERM STORAGE ACCOUNT BLOB CONTAINER SAS DATA SOURCE
##
## Create a SAS Token to append to the Blob URL for deployment in Azure Function App. Deployment in a Private bucket
## requires SAS Token to authenticate and download from within Azure Function.
##
## Parameters:
## - `connection_string`: ADLS bucket abfss connection string.
## - `container_name`: ADLS container name.
## - `https`: Secure HTTP connections only.
## - `start`: SAS token start date/time.
## - `expiry`: SAS token expiry date/time.
## ---------------------------------------------------------------------------------------------------------------------
data "azurerm_storage_account_blob_container_sas" "this" {
  provider = azurerm.auth_session

  connection_string = var.function_bucket_connection
  container_name    = var.function_container_name
  https_only        = true

  start  = timestamp()
  expiry = timeadd(timestamp(), var.function_sas_token_expiry)

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = true
  }
}
