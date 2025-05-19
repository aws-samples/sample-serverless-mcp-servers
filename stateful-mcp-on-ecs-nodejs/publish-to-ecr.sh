#!/bin/bash
ECR_REPO=stateful-mcp-on-ecs
ECR_IMAGE_TAG=latest
ECR_ALIAS=your-ecr-alias-here
ECR_REPO_URI=public.ecr.aws/${ECR_ALIAS}/$ECR_REPO:$ECR_IMAGE_TAG

echo Logging in...
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws

echo Incrementing app version...
cd src/mcpserver
npm version patch

echo Building image and publishing to Public ECR...
aws ecr-public create-repository --repository-name $ECR_REPO --no-cli-pager
docker buildx build --platform linux/amd64 --provenance=false -t $ECR_REPO_URI . --push

echo All done!
