#!/usr/bin/env python3

import json


def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "event": event,
        })
    }
