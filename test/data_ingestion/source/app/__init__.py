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
from flask import Flask, jsonify, request
from werkzeug.utils import secure_filename

# Environment Variables
OUTPUT_BUCKET = os.getenv("OUTPUT_BUCKET_NAME")
OUTPUT_BUCKET_CONTAINER_NAME = os.getenv("OUTPUT_BUCKET_CONTAINER_NAME")
OUTPUT_BUCKET_KEY = os.getenv("OUTPUT_BUCKET_KEY", None)

# Setup
logging.basicConfig(stream=sys.stdout, level=logging.INFO)
flask_app = Flask(__name__)


@flask_app.route("/", methods=["POST"])
def run():
    try:
        logging.info("HTTP Request Received")
        if "files" not in request.files:
            return jsonify({"error": "No file part"}), 400

        fs = adlfs.AzureBlobFileSystem(
            account_name=OUTPUT_BUCKET, account_key=OUTPUT_BUCKET_KEY
        )
        for file in request.files.getlist("files"):
            logging.info(
                f"HTTP Request: {secure_filename(file.filename)} | Initiating Data Ingestion"
            )
            with fs.open(
                os.path.join(
                    OUTPUT_BUCKET_CONTAINER_NAME, secure_filename(file.filename)
                ),
                "wb",
            ) as f:
                file.save(f)

        return "Data Ingestion Succesfull", 200

    except Exception as e:
        logging.error(f"Error: {e}")
        return "Data Ingestion Failed", 500
