"""
Unit Test: HTTP-triggered Azure Function File Upload

This unit test verifies the functionality of an Azure Function triggered
by HTTP requests. The function is expected to receive a
file upload (in the HTTP request body) and a filename (as a query parameter),
and write the file to an Azure Blob Storage container specified by the
STORAGE_ACCOUNT_NAME and TARGET_CONTAINER_NAME environment variables.

The test sends a sample JSON payload to the function's HTTP endpoint and then
checks that the file has been correctly written to the storage container. This ensures the
function's HTTP integration and Blob Storage write logic are functioning as intended.

Environment Variables Required:
 - STORAGE_ACCOUNT_NAME: Name of the Azure Storage Account.
 - TARGET_CONTAINER_NAME: Name of the container within the storage account where files will be written.
 - STORAGE_ACCOUNT_KEY: Access key for the storage account (for local/env testing).
 - FUNCTION_URL: The HTTP endpoint for the Azure Function.

Local Testing Steps:
```
terraform -chdir=./test/service_account init && \
terraform -chdir=./test/service_account apply -auto-approve

terraform -chdir=./test/data_ingestion init && \
terraform -chdir=./test/data_ingestion apply -auto-approve

export AZURE_FUNCTION_API_ENDPOINT=$(terraform -chdir=./test/data_ingestion output -raw function_api_endpoint)
export AZURE_FUNCTION_API_X_KEY=$(terraform -chdir=./test/data_ingestion output -raw function_default_x_key)
export AZURE_STORAGE_ACCOUNT_NAME=$(terraform -chdir=./test/data_ingestion output -raw bronze_bucket_name)
export AZURE_TARGET_CONTAINER_NAME=$(terraform -chdir=./test/data_ingestion output -raw bronze_bucket_name)
export AZURE_STORAGE_ACCOUNT_KEY=$(terraform -chdir=./test/data_ingestion output -raw bronze_bucket_key)

cd test/data_ingestion/unit_test
# Ensure you have installed dependencies: pip install pytest requests azure-storage-blob azure-identity
python3 -m pytest -m 'local and env'

cd ../../..
terraform -chdir=./test/data_ingestion destroy -auto-approve
terraform -chdir=./test/service_account destroy -auto-approve
```
"""

import json
import logging
import os
import time
import uuid

import pytest
import requests
from azure.identity import DefaultAzureCredential
from azure.storage.blob import BlobServiceClient

# Environment Variables
AZURE_STORAGE_ACCOUNT_NAME = os.getenv("AZURE_STORAGE_ACCOUNT_NAME")
AZURE_TARGET_CONTAINER_NAME = os.getenv("AZURE_TARGET_CONTAINER_NAME")
AZURE_STORAGE_ACCOUNT_KEY = os.getenv("AZURE_STORAGE_ACCOUNT_KEY")
AZURE_FUNCTION_API_ENDPOINT = f"https://{os.getenv('AZURE_FUNCTION_API_ENDPOINT')}"
AZURE_FUNCTION_API_X_KEY = os.getenv("AZURE_FUNCTION_API_X_KEY")

assert AZURE_STORAGE_ACCOUNT_NAME is not None
assert AZURE_TARGET_CONTAINER_NAME is not None
assert AZURE_STORAGE_ACCOUNT_KEY is not None
assert AZURE_FUNCTION_API_ENDPOINT is not None
assert AZURE_FUNCTION_API_X_KEY is not None


def _read_blob_from_azure(filename, use_oidc=False):
    """
    Reads a JSON file from Azure Blob Storage.
    If use_oidc is True, uses DefaultAzureCredential for authentication (for workload identity).
    Otherwise, uses the storage account key from environment variables.

    Args:
        filename (str): The name of the file to read.
        use_oidc (bool, optional): Whether to use OIDC-based credentials. Defaults to False.

    Returns:
        dict: The JSON content of the file.
    """
    if use_oidc:
        credential = DefaultAzureCredential()
        blob_service_client = BlobServiceClient(
            account_url=f"https://{AZURE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net",
            credential=credential,
        )
    else:
        assert AZURE_STORAGE_ACCOUNT_KEY is not None
        connection_string = f"DefaultEndpointsProtocol=https;AccountName={AZURE_STORAGE_ACCOUNT_NAME};AccountKey={AZURE_STORAGE_ACCOUNT_KEY};EndpointSuffix=core.windows.net"
        blob_service_client = BlobServiceClient.from_connection_string(
            connection_string
        )

    blob_client = blob_service_client.get_blob_client(
        container=AZURE_TARGET_CONTAINER_NAME, blob=filename
    )
    downloader = blob_client.download_blob()
    return json.loads(downloader.readall())


@pytest.mark.local
@pytest.mark.env
def test_azure_env_http_function_file_upload(payload=None):
    """
    Test uploading a file to the Azure Function via HTTP POST and verifying it's written to Blob Storage.
    Uses storage account key from environment for access.

    Args:
        payload (dict, optional): The JSON payload to upload. If None, a random payload is generated.
    """
    logging.info("Pytest | Test HTTP Function File Upload with Environment Credentials")
    if payload is None:
        payload = {"test_value": str(uuid.uuid4())}
    filename = f"test-env-{str(uuid.uuid4())}.json"

    # Send HTTP POST to Azure Function
    response = requests.post(
        AZURE_FUNCTION_API_ENDPOINT,
        params={"name": filename},
        data=json.dumps(payload),
        headers={
            "Content-Type": "application/json",
            "X-functions-key": AZURE_FUNCTION_API_X_KEY,
        },
    )

    assert response.status_code == 200, f"Function HTTP call failed: {response.text}"

    # Wait for the function to write to Blob Storage
    time.sleep(5)

    # Verify the file was written to Blob Storage
    rs = _read_blob_from_azure(filename, use_oidc=False)
    assert rs["test_value"] == payload["test_value"]


@pytest.mark.github
@pytest.mark.oidc
def test_azure_oidc_http_function_file_upload(payload=None):
    """
    Test uploading a file to the Azure Function via HTTP POST and verifying it's written to Blob Storage.
    Uses OIDC and Workload Identity (DefaultAzureCredential) for Blob Storage access.

    Args:
        payload (dict, optional): The JSON payload to upload. If None, a random payload is generated.
    """
    logging.info("Pytest | Test HTTP Function File Upload with OIDC Credentials")

    if payload is None:
        payload = {"test_value": str(uuid.uuid4())}
    filename = f"test-oidc-{str(uuid.uuid4())}.json"

    # Send HTTP POST to Azure Function
    response = requests.post(
        AZURE_FUNCTION_API_ENDPOINT,
        params={"name": filename},
        data=json.dumps(payload),
        headers={
            "Content-Type": "application/json",
            "X-functions-key": AZURE_FUNCTION_API_X_KEY,
        },
    )

    assert response.status_code == 200, f"Function HTTP call failed: {response.text}"

    # Wait for the function to write to Blob Storage
    time.sleep(5)

    # Verify the file was written to Blob Storage using OIDC
    rs = _read_blob_from_azure(filename, use_oidc=True)
    assert rs["test_value"] == payload["test_value"]
