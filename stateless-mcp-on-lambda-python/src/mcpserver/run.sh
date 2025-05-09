#!/bin/bash

export PATH=$PATH:$LAMBDA_TASK_ROOT/bin
export PYTHONPATH=$PYTHONPATH:/opt/python:$LAMBDA_RUNTIME_DIR
exec python -m uvicorn --port=$PORT server:app