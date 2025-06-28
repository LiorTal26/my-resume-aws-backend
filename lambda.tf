# -------------------------------------------------------------------
#  Package Lambda code → lambda.zip
# -------------------------------------------------------------------
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_src/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}

# -------------------------------------------------------------------
#  Re-use existing IAM role
# -------------------------------------------------------------------
data "aws_iam_role" "lambda_role" {
  name = "lambda-resume" # or "service-role/lambda-resume"
}

resource "aws_iam_role_policy" "ddb_access" {
  role = data.aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["dynamodb:GetItem", "dynamodb:UpdateItem"],
      Resource = aws_dynamodb_table.counter.arn # <— still references the table
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_exec" {
  role       = data.aws_iam_role.lambda_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# -------------------------------------------------------------------
#  Lambda function
# -------------------------------------------------------------------
resource "aws_lambda_function" "visitor_fn" {
  function_name = var.lambda_name
  role          = data.aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.counter.name
    }
  }

  depends_on = [
    data.archive_file.lambda_zip,
    aws_iam_role_policy.ddb_access
  ]
}
