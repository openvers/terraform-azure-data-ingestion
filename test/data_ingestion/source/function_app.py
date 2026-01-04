"""Azure Functions Application Example

An Azure Functions Application with a HTTP Trigger is a
serverless function that automatically executes in response to HTTP requests.
This function will write the contents of HTTP request into file of the
OUTPUT Blob Store given the filename passed into HTTP request parameter "name".
This trigger mechanism  enables event-driven architecture and allows you to build
scalable and event-based solutions on Azure.

"""

import logging
import os
import sys
import uuid

import adlfs
import azure.functions as func

# Environment Variables
OUTPUT_BUCKET = os.getenv("OUTPUT_BUCKET_NAME")
OUTPUT_BUCKET_CONTAINER_NAME = os.getenv("OUTPUT_BUCKET_CONTAINER_NAME")
OUTPUT_BUCKET_KEY = os.getenv("OUTPUT_BUCKET_KEY", None)

# Setup
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


def extract_file_from_req(request: func.HttpRequest):
    """
    Extracts the file content and name from an HTTP request.

    Args:
        request (func.HttpRequest): The HTTP request object.

    Returns:
        tuple: A tuple containing the file content and name.
    """
    try:
        file_bytes = request.get_body()
        file_name = request.params.get("name") or str(uuid.uuid4()) + ".bin"
    except Exception as e:
        logging.error(f"Error processing request: {e}")
        return func.HttpResponse(
            f"An error occurred while uploading the file. {str(e)}", status_code=400
        )

    logging.debug(f"Extracted file '{file_name}' with size {len(file_bytes)} bytes.")
    return file_bytes, os.path.join(OUTPUT_BUCKET_CONTAINER_NAME, file_name)


@app.function_name(name="example-function")
@app.route(route="main")
def main(req: func.HttpRequest) -> func.HttpResponse:
    """
    Uploads a file to Azure Blob Storage.

    Args:
        req (func.HttpRequest): The HTTP request object.
        outputBlob (func.Out[bytes]): The output binding for the file content.

    Returns:
        func.HttpResponse: A response indicating the success or failure of the upload.
    """
    logging.info("Python HTTP trigger function processed a request.")

    try:
        file_bytes, file_name = extract_file_from_req(req)

        logging.debug(
            f"Establishing Azure Blob Storage connection to {OUTPUT_BUCKET}..."
        )
        fs = adlfs.AzureBlobFileSystem(
            account_name=OUTPUT_BUCKET, account_key=OUTPUT_BUCKET_KEY
        )

        logging.debug(f"Writing file '{file_name}' with size {len(file_bytes)} bytes.")
        with fs.open(file_name, "wb") as f:
            f.write(file_bytes)

        # Return a success response
        return func.HttpResponse(
            f"File '{file_name}' uploaded successfully to mycontainer.", status_code=200
        )
    except Exception as e:
        logging.error(f"Error processing request: {e}")
        return func.HttpResponse(
            f"An error occurred while uploading the file. {str(e)}", status_code=400
        )
