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

import adlfs
import azure.functions as func

# Environment Variables
OUTPUT_BUCKET = os.getenv("OUTPUT_BUCKET_NAME")
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
            "An error occurred while uploading the file.", status_code=400
        )

    return file_bytes, file_name


@app.route(route="uploadfile")
@app.blob_output(
    arg_name="outputBlob", path="mycontainer/{name}", connection="AzureWebJobsStorage"
)
def uploadfile(req: func.HttpRequest, outputBlob: func.Out[bytes]) -> func.HttpResponse:
    """
    Uploads a file to Azure Blob Storage.

    Args:
        req (func.HttpRequest): The HTTP request object.
        outputBlob (func.Out[bytes]): The output binding for the file content.

    Returns:
        func.HttpResponse: A response indicating the success or failure of the upload.
    """
    logging.info("Python HTTP trigger function processed a request.")

    file_bytes, file_name = extract_file_from_req(req)
    # Write the file content to the output binding
    # outputBlob.set(file_bytes)
    fs = adlfs.AzureBlobFileSystem(
        account_name=OUTPUT_BUCKET, account_key=OUTPUT_BUCKET_KEY
    )

    with fs.open(file_name, "wb") as f:
        f.write(file_bytes)

    # Return a success response
    return func.HttpResponse(
        f"File '{file_name}' uploaded successfully to mycontainer.", status_code=200
    )
