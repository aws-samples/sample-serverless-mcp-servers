#!/bin/bash

export PATH=$PATH:$LAMBDA_TASK_ROOT/bin
export PYTHONPATH=$PYTHONPATH:/opt/python:$LAMBDA_RUNTIME_DIR

# direct to fastapi
# exec python -m uvicorn --port=$PORT server_fastapi:app
# direct to fastmcp
exec python -m uvicorn --port=$PORT server:app
