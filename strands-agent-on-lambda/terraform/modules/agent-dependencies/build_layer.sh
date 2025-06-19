#!/bin/bash
set -e
echo Preparing dependencies...
mkdir -p out/python
pip install -r requirements.txt -t out/python/
cd out
zip -r layer.zip ./*
