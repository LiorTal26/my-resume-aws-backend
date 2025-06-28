output "website_bucket_url" {
  description = "Raw S3 website endpoint (HTTP)"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "cloudfront_url" {
  description = "Global HTTPS URL for your résumé"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "api_gateway_url" {
  description = "Visitor counter API endpoint"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/visitors"
}
output "lambda_function_name" {
  description = "Name of the Lambda function for visitor counting"
  value       = aws_lambda_function.visitor_fn.function_name
}
# dynamodb.tf or outputs.tf
output "ddb_table_name" {
  value       = aws_dynamodb_table.counter.name
  description = "Name of the visitor counter DynamoDB table"
}


output "cloud_resume_challenge_aws" {
  value       = "https://cloudresumechallenge.dev/docs/the-challenge/aws/"
  description = "Link to the Cloud Resume Challenge AWS documentation"
}