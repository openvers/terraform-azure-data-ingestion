"""Azure Functions Application Example

An Azure Functions Application with a HTTP Trigger is a
serverless function that automatically executes in response to HTTP requests.
This function will write the contents of HTTP request into file of the
OUTPUT Blob Store given the filename passed into HTTP request parameter "name".
This trigger mechanism  enables event-driven architecture and allows you to build
scalable and event-based solutions on Azure.

"""

import azure.functions as func
from app import flask_app

# Setup
azure_app = func.FunctionApp(http_auth_level=func.AuthLevel.ANONYMOUS)


@azure_app.function_name(name="example-function")
@azure_app.route(route="{*route}")
def main(req: func.HttpRequest, context: func.Context) -> func.HttpResponse:
    return func.WsgiMiddleware(flask_app.wsgi_app).handle(req, context)
