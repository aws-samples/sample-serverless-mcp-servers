resource "aws_iam_role" "authorizer" {
  name = "${local.project_name}-authorizer"
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

resource "aws_iam_role_policy_attachment" "authorizer" {
  role       = aws_iam_role.authorizer.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "authorizer" {
  type        = "zip"
  source_dir  = "${path.root}/../src/js/authorizer"
  output_path = "${path.root}/tmp/authorizer.zip"
}

resource "aws_lambda_function" "authorizer" {
  function_name    = "${local.project_name}-authorizer"
  filename         = data.archive_file.authorizer.output_path
  source_code_hash = data.archive_file.authorizer.output_base64sha256
  role             = aws_iam_role.authorizer.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  memory_size      = 256
  timeout          = 5
}

