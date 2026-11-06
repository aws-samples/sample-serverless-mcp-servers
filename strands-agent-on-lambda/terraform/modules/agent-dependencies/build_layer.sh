#!/bin/bash
set -e
echo Preparing dependencies...
# Start from a clean output dir: pip -t does not replace packages left over from a previous build
rm -rf out/python out/layer.zip
mkdir -p out/python
pip install -r requirements.txt -t out/python/
cd out
zip -r layer.zip ./*
