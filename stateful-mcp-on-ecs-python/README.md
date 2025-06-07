# Stateful MCP Server on ECS

This repository contains a sample serverless MCP (Model Context Protocol) server implementation using the official MCP SDK and Python. The server provides a simple echo functionality and can be deployed on ECS Fargate.

## Overview

This project implements a stateful MCP server that:
- Uses FastMCP and optionally FastAPI
- Implements a simple echo tool that returns the input message
- Can be containerized and deployed on AWS ECS

## Prerequisites

- Python 3.12 or higher
- Podman (Docker alternative)
- AWS CLI configured with appropriate credentials
- AWS SAM CLI (for deployment)

If you are using Docker, update `makefile`, replacing `podman` references with `docker`.

## Project Structure

```
stateful-mcp-on-ecs-python/
├── src/
│   ├── server.py      # Main server implementation
│   └── echo.py        # Echo tool implementation
├── sam/               # AWS SAM templates
├── etc/               # Configuration files
├── dockerfile         # Docker configuration
├── requirements.txt   # Python dependencies
└── makefile           # Build and deployment commands
```

## Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd stateful-mcp-on-ecs-python
   ```
2. Update the variables in `etc/environment.sh` to reflect values for your AWS account and environment

## Deployment Process

The deployment process consists of three main steps:

### 1. Deploy Core Infrastructure

First, deploy the core infrastructure components:

```bash
make infrastructure
```

After the infrastructure deployment completes:
1. Note the outputs from the CloudFormation stack
2. Update the variables in `environment.sh` with the appropriate values from the stack outputs

### 2. Build and Push Container Image

Build the container image and push it to ECR:

```bash
make podman
```

This will:
- Build the container image using Podman
- Tag the image with the current version
- Push the image to the ECR repository

### 3. Deploy ECS Resources

Deploy the ECS resources:

```bash
make ecs
```

This will create:
- Load balancer with an ACM certificate
- ECS cluster
- Task definition
- Service

## Versioning

When deploying new versions of the container:

1. Update the `C_VERSION` parameter in your environment or deployment configuration
2. Follow the deployment process starting from step 2 (build and push container image)
3. The ECS service will automatically update to use the new container version

## Available Make Commands

- `make infrastructure`: Deploy core AWS infrastructure
- `make podman`: Build and push container image
- `make ecs`: Deploy ECS resources

## Testing

When connecting to your MCP server on Fargate with MCP Inspector, be sure to connect using the following URL: `https://<your.domain.com>/mcp/`

Note that the trailing `/` is important when connecting, as the FastMCP server will perform a 307 redirect without it.
