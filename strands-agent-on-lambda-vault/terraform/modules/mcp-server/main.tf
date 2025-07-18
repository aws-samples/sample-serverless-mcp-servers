data "aws_region" "current" {}

locals {
  lwa_layer_arn_arm64 = "arn:aws:lambda:${data.aws_region.current.name}:753240598075:layer:LambdaAdapterLayerArm64:25"
  lwa_layer_arn_x86   = "arn:aws:lambda:${data.aws_region.current.name}:753240598075:layer:LambdaAdapterLayerX86:25"
  lwa_layer_arn       = var.fn_architecture == "arm64" ? local.lwa_layer_arn_arm64 : local.lwa_layer_arn_x86
}

data "archive_file" "bookings_mcp_server" {
  type        = "zip"
  source_dir  = "${path.root}/../lambdas/bookings-mcp"
  output_path = "${path.root}/tmp/bookings-mcp.zip"
}

resource "aws_lambda_function" "bookings_mcp_server" {
  function_name    = "bookings-mcp-server"
  architectures    = [var.fn_architecture]
  runtime          = "nodejs22.x"
  handler          = "run.sh"
  timeout          = 10
  memory_size      = 1024
  role             = aws_iam_role.bookings_mcp_server_lambda.arn
  filename         = data.archive_file.bookings_mcp_server.output_path
  source_code_hash = data.archive_file.bookings_mcp_server.output_base64sha256
  layers           = [local.lwa_layer_arn]

  environment {
    variables = {
      AWS_LAMBDA_EXEC_WRAPPER = "/opt/bootstrap"
      AWS_LWA_PORT            = "3001"
      JWT_SIGNATURE_SECRET    = var.jwt_signature_secret
    }
  }
}

data "archive_file" "mcp_authorizer" {
  type        = "zip"
  source_dir  = "${path.root}/../lambdas/mcp-authorizer"
  output_path = "${path.root}/tmp/mcp-authorizer.zip"
}

resource "aws_lambda_function" "mcp_authorizer" {
  function_name    = "bookings-mcp-server-authorizer"
  architectures    = [var.fn_architecture]
  runtime          = "nodejs22.x"
  handler          = "index.handler"
  timeout          = 10
  memory_size      = 1024
  role             = aws_iam_role.mcp_authorizer_lambda.arn
  filename         = data.archive_file.mcp_authorizer.output_path
  source_code_hash = data.archive_file.mcp_authorizer.output_base64sha256
  environment {
    variables = {
      JWT_SIGNATURE_SECRET = var.jwt_signature_secret
    }
  }
}

resource "aws_api_gateway_rest_api" "mcp_api" {
  name = "bookings-mcp-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "mcp_resource" {
  rest_api_id = aws_api_gateway_rest_api.mcp_api.id
  parent_id   = aws_api_gateway_rest_api.mcp_api.root_resource_id
  path_part   = "mcp"
}

resource "aws_api_gateway_authorizer" "mcp_authorizer" {
  name                   = "bookings-mcp-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.mcp_api.id
  authorizer_uri         = aws_lambda_function.mcp_authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.mcp_authorizer_apigw.arn
  identity_source        = "method.request.header.Authorization"
  type                   = "TOKEN"
}

resource "aws_api_gateway_method" "mcp_method" {
  rest_api_id   = aws_api_gateway_rest_api.mcp_api.id
  resource_id   = aws_api_gateway_resource.mcp_resource.id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.mcp_authorizer.id
}

resource "aws_api_gateway_integration" "mcp_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mcp_api.id
  resource_id             = aws_api_gateway_resource.mcp_resource.id
  http_method             = aws_api_gateway_method.mcp_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.bookings_mcp_server.invoke_arn
}

resource "aws_lambda_permission" "invoke_from_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bookings_mcp_server.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.mcp_api.execution_arn}/*/${aws_api_gateway_method.mcp_method.http_method}${aws_api_gateway_resource.mcp_resource.path}"
}

resource "aws_api_gateway_deployment" "mcp_deployment" {
  depends_on = [aws_api_gateway_integration.mcp_integration]
  rest_api_id = aws_api_gateway_rest_api.mcp_api.id

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeploy = timestamp()
  }
}

resource "aws_api_gateway_stage" "mcp_stage" {
  deployment_id = aws_api_gateway_deployment.mcp_deployment.id
  rest_api_id = aws_api_gateway_rest_api.mcp_api.id
  stage_name = "dev"
}