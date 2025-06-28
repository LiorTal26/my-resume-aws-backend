# Zip up the handler
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}

#   IAM role + policies
data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "resume-counter-role"
  description        = "Exec role for resume-counter Lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json

  lifecycle { create_before_destroy = true }
}

# CloudWatch Logs
resource "aws_iam_role_policy_attachment" "basic_exec" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DynamoDB read/write for the counter table
data "aws_iam_policy_document" "ddb_access" {
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.counter.arn]
  }
}

resource "aws_iam_policy" "ddb_policy" {
  name        = "resume-counter-ddb-policy"
  policy      = data.aws_iam_policy_document.ddb_access.json
  description = "Allow Lambda to read/update visitor counter table"
}

resource "aws_iam_role_policy_attachment" "ddb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.ddb_policy.arn
}

#  2.  Lambda function
resource "aws_lambda_function" "visitor_fn" {
  function_name = var.lambda_name # "resume-counter"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  memory_size = 128
  timeout     = 5

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.counter.name
    }
  }

  publish = true

  depends_on = [
    aws_iam_role_policy_attachment.basic_exec,
    aws_iam_role_policy_attachment.ddb_attach,
  ]
}

#  3.  (Optional) Stable alias “live” that always points to the newest version
resource "aws_lambda_alias" "live" {
  name             = "live"
  function_name    = aws_lambda_function.visitor_fn.function_name
  function_version = aws_lambda_function.visitor_fn.version
}

