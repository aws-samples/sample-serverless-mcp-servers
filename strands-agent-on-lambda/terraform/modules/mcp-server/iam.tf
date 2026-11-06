resource "aws_iam_role" "bookings_mcp_server_lambda" {
  name = "bookings-mcp-server-lambda-role"

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

resource "aws_iam_role_policy_attachment" "bookings_mcp_server" {
  role       = aws_iam_role.bookings_mcp_server_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "mcp_authorizer_lambda" {
  name = "mcp-authorizer-lambda-role"

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

resource "aws_iam_role_policy_attachment" "mcp_authorizer_lambda" {
  role       = aws_iam_role.mcp_authorizer_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "mcp_authorizer_apigw" {
  name = "mcp-authorizer-apigw-role"

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

resource "aws_iam_role_policy" "mcp_authorizer_apigw" {
  name = "mcp-authorizer-apigw-policy"
  role = aws_iam_role.mcp_authorizer_apigw.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = aws_lambda_function.mcp_authorizer.arn
      }
    ]
  })
}

# Both MCP Server and MCP Authorizer load the JWT signature secret on startup
resource "aws_iam_policy" "read_jwt_signature_secret" {
  name = "bookings-mcp-read-jwt-signature-secret-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "secretsmanager:GetSecretValue"
      Effect   = "Allow"
      Resource = aws_secretsmanager_secret.jwt_signature_secret.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "bookings_mcp_server_read_jwt_signature_secret" {
  role       = aws_iam_role.bookings_mcp_server_lambda.name
  policy_arn = aws_iam_policy.read_jwt_signature_secret.arn
}

resource "aws_iam_role_policy_attachment" "mcp_authorizer_read_jwt_signature_secret" {
  role       = aws_iam_role.mcp_authorizer_lambda.name
  policy_arn = aws_iam_policy.read_jwt_signature_secret.arn
}
