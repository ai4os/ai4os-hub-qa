#!/usr/bin/env python3

import os

from oscar_python import client_anon

# READ from env vars
ENDPOINT = os.environ.get('OSCAR_ENDPOINT', None)
SERVICE_NAME = os.environ.get('OSCAR_SERVICE_NAME', 'update-modules-service')
SERVICE_TOKEN = os.environ.get('OSCAR_SERVICE_TOKEN', None)
METADATA_PATH = os.environ.get('METADATA_PATH', 'metadata.json')
CLUSTER_ID = os.environ.get('OSCAR_CLUSTER_ID', 'oscar-ai4eosc')

if SERVICE_TOKEN is None:
    raise ValueError("OSCAR_SERVICE_TOKEN is not set")

if ENDPOINT is None:
    raise ValueError("OSCAR_ENDPOINT is not set")

client = client_anon.AnonymousClient({
    'cluster_id': CLUSTER_ID,
    'endpoint': ENDPOINT,
    'ssl': 'true'
})

client.run_service(SERVICE_NAME, token=SERVICE_TOKEN, input=METADATA_PATH)
