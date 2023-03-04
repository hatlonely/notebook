#!/usr/bin/env python3


import base64
import requests


def handler(event, context):
    res = requests.request(
        method=event["requestContext"]["http"]["method"].lower(),
        url="http://127.0.0.1:8000{}?{}".format(event["rawPath"], event["rawQueryString"]),
        data=base64.b64decode(event["body"]).decode(),
        headers={
            "Content-Type": "application/x-www-form-urlencoded"
        },
    )

    return {
        "statusCode": res.status_code,
        "headers": dict(res.headers),
        "body": res.text,
    }
