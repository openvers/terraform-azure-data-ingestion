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

import io
import json
import logging
import os
import time
import uuid

import adlfs
import pytest
import requests

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
        url=AZURE_FUNCTION_API_ENDPOINT,
        headers={
            "X-functions-key": AZURE_FUNCTION_API_X_KEY,
        },
        files=[("files", (filename, io.BytesIO(json.dumps(payload).encode("utf-8"))))],
    )

    assert response.status_code == 200, f"Function HTTP call failed: {response.text}"

    # Verify the file was written to Blob Storage
    fs = adlfs.AzureBlobFileSystem(
        account_name=AZURE_STORAGE_ACCOUNT_NAME, account_key=AZURE_STORAGE_ACCOUNT_KEY
    )
    with fs.open(os.path.join(AZURE_TARGET_CONTAINER_NAME, filename), "r") as f:
        rs = json.load(f)
        assert rs["test_value"] == payload["test_value"]
