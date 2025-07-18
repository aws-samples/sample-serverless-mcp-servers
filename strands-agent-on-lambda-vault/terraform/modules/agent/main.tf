data "aws_region" "current" {}

resource "aws_dynamodb_table" "agent_state_table" {
  name         = "travel-agent-on-lambda-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }
}

data "archive_file" "travel_agent" {
  type        = "zip"
  source_dir  = "${path.root}/../lambdas/travel-agent"
  output_path = "${path.root}/tmp/travel-agent.zip"
}

resource "aws_lambda_function" "travel_agent" {
  function_name = "travel-agent-on-lambda"
  architectures = [var.fn_architecture]
  runtime       = "python3.13"
  handler       = "app.handler"
  timeout       = 30
  memory_size   = 1024
  role          = aws_iam_role.travel_agent_lambda.arn

  filename         = data.archive_file.travel_agent.output_path
  source_code_hash = data.archive_file.travel_agent.output_sha256

  layers = [var.fn_dependecies_layer_arn]

  environment {
    variables = {
      MCP_ENDPOINT         = var.mcp_endpoint
      JWT_SIGNATURE_SECRET = var.jwt_signature_secret
      STATE_TABLE_NAME     = aws_dynamodb_table.agent_state_table.name
      VAULT_OIDC_JWKS_URL  = var.oidc_jwks_url
    }
  }
}

data "archive_file" "agent_authorizer" {
  type        = "zip"
  source_dir  = "${path.root}/../lambdas/agent-authorizer"
  output_path = "${path.root}/tmp/agent-authorizer.zip"
}

resource "aws_lambda_function" "agent_authorizer" {
  function_name = "travel-agent-authorizer"
  architectures = [var.fn_architecture]
  runtime       = "nodejs22.x"
  handler       = "index.handler"
  timeout       = 10
  memory_size   = 1024
  role          = aws_iam_role.travel_agent_authorizer_lambda.arn

  filename         = data.archive_file.agent_authorizer.output_path
  source_code_hash = data.archive_file.agent_authorizer.output_base64sha256

    environment {
    variables = {
      VAULT_OIDC_JWKS_URL = var.oidc_jwks_url
    }
  }
}

# API Gateway REST API
resource "aws_api_gateway_rest_api" "agent_api" {
  name = "travel-agent-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "agent_authorizer" {
  name                   = "agent-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.agent_api.id
  authorizer_uri         = aws_lambda_function.agent_authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.travel_agent_authorizer_apigw.arn
  identity_source        = "method.request.header.Authorization"
  type                   = "TOKEN"
}

resource "aws_api_gateway_method" "agent_method" {
  rest_api_id   = aws_api_gateway_rest_api.agent_api.id
  resource_id   = aws_api_gateway_rest_api.agent_api.root_resource_id
  http_method   = "POST"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.agent_authorizer.id
}

resource "aws_api_gateway_integration" "agent_integration" {
  rest_api_id             = aws_api_gateway_rest_api.agent_api.id
  resource_id             = aws_api_gateway_rest_api.agent_api.root_resource_id
  http_method             = aws_api_gateway_method.agent_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.travel_agent.invoke_arn
}

resource "aws_api_gateway_deployment" "agent_deployment" {
  depends_on = [aws_api_gateway_integration.agent_integration]
  rest_api_id = aws_api_gateway_rest_api.agent_api.id

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeploy = timestamp()
  }
}

resource "aws_api_gateway_stage" "agent_stage" {
  deployment_id = aws_api_gateway_deployment.agent_deployment.id
  rest_api_id = aws_api_gateway_rest_api.agent_api.id
  stage_name = "dev"
}