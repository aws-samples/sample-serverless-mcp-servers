resource "aws_iam_role" "mcp_server" {
  name = local.project_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mcp_server" {
  role       = aws_iam_role.mcp_server.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "mcp_server" {
  type        = "zip"
  source_dir  = "${path.root}/../src/js/mcpserver"
  output_path = "${path.root}/tmp/mcpserver.zip"
}

resource "aws_lambda_function" "mcp_server" {
  function_name    = local.project_name
  filename         = data.archive_file.mcp_server.output_path
  source_code_hash = data.archive_file.mcp_server.output_base64sha256
  role             = aws_iam_role.mcp_server.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  memory_size      = 512
  timeout          = 10
}

