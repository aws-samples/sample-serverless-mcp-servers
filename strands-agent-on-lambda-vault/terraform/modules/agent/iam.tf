resource "aws_iam_role" "travel_agent_lambda" {
  name = "travel-agent-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "travel_agent_lambda_basic" {
  role       = aws_iam_role.travel_agent_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "travel_agent_lambda_bedrock" {
  name        = "travel-agent-lambda-bedrock-policy" 
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "travel_agent_lambda_bedrock" {
  role       = aws_iam_role.travel_agent_lambda.name
  policy_arn = aws_iam_policy.travel_agent_lambda_bedrock.arn
}

resource "aws_iam_policy" "travel_agent_lambda_ddb" {
  name        = "travel-agent-lambda-ddb-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ]
      Effect   = "Allow"
      Resource = aws_dynamodb_table.agent_state_table.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "travel_agent_dynamodb" {
  role       = aws_iam_role.travel_agent_lambda.name
  policy_arn = aws_iam_policy.travel_agent_lambda_ddb.arn
}

resource "aws_iam_role" "travel_agent_authorizer_lambda" {
  name = "travel-agent-authorizer-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "travel_agent_authorizer_lambda" {
  role       = aws_iam_role.travel_agent_authorizer_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "travel_agent_authorizer_apigw" {
  name = "travel-agent-authorizer-apigw-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "travel_agent_authorizer_apigw" {
  name = "travel-agent-authorizer-apigw-policy"
  role = aws_iam_role.travel_agent_authorizer_apigw.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = [aws_lambda_function.agent_authorizer.arn]
      }
    ]
  })
}

resource "aws_lambda_permission" "invoke_from_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.travel_agent.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.agent_api.execution_arn}/*/${aws_api_gateway_method.agent_method.http_method}/"
}

