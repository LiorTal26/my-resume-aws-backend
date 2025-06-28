#  DynamoDB table for the visitor counter
resource "aws_dynamodb_table" "counter" {
  name         = var.ddb_table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"
  attribute {
    name = "id"
    type = "S"
  }
}
