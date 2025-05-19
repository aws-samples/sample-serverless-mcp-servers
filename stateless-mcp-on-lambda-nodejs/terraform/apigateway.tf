resource "aws_api_gateway_rest_api" "api" {
  name = local.project_name
  lifecycle {
    create_before_destroy = true
  }  
}

resource "aws_api_gateway_resource" "mcp" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "mcp"
}

resource "aws_api_gateway_method" "any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.mcp.id
  # Change authorization from NONE to CUSTOM to enable custom Lambda authorizer
  # Note: it might take up to 60 seconds for API Gateway configuration
  #       change to take effect
  authorization = "NONE"
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
  http_method   = "ANY"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.mcp.id
  http_method             = aws_api_gateway_method.any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.mcp_server.invoke_arn
}

resource "aws_lambda_permission" "apigw_to_mcp_server" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mcp_server.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  depends_on  = [aws_api_gateway_method.any, aws_api_gateway_integration.lambda]
  lifecycle {
    create_before_destroy = true
  }
  triggers = {
    redeployment = timestamp() //always
  }
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.api.id
  stage_name    = "dev"
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name                             = "mcp-authorizer"
  rest_api_id                      = aws_api_gateway_rest_api.api.id
  type                             = "TOKEN"
  authorizer_uri                   = aws_lambda_function.authorizer.invoke_arn
  authorizer_result_ttl_in_seconds = 0
  identity_source                  = "method.request.header.Authorization"
  # authorizer_uri                   = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.authorizer.arn}/invocations"
}

resource "aws_lambda_permission" "apigw_to_authorizer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/authorizers/*"
}
