
# -------- HTTP API --------------------------------------------------
resource "aws_apigatewayv2_api" "http_api" {
  name          = "resume-visitor-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_methods = ["GET", "POST"]
    allow_origins = ["*"]
  }
}

# -------- Lambda proxy integration ---------------------------------
resource "aws_apigatewayv2_integration" "lambda_integ" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.visitor_fn.invoke_arn
  payload_format_version = "2.0"
}

# -------- Routes: GET & POST ---------------------------------------
resource "aws_apigatewayv2_route" "visitors_get" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /visitors"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integ.id}"
}

resource "aws_apigatewayv2_route" "visitors_post" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /visitors"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integ.id}"
}

# -------- Stage -----------------------------------------------------
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# -------- Lambda permissions ---------------------------------------
resource "aws_lambda_permission" "api_invoke_get" {
  statement_id  = "AllowAPIG-${aws_apigatewayv2_api.http_api.id}-GET"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_fn.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/GET/visitors"
}

resource "aws_lambda_permission" "api_invoke_post" {
  statement_id  = "AllowAPIG-${aws_apigatewayv2_api.http_api.id}-POST"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_fn.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/POST/visitors"
}

#  NEW — Custom domain for the API  (api.lior-cv.tal-handassa.com)
resource "aws_apigatewayv2_domain_name" "api_domain" {
  domain_name = "${var.api_sub}.${var.domain_root}" # api.lior-cv.tal-handassa.com

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.api_cert.arn # il-central-1 cert
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# Map the HTTP API default stage to the custom domain
resource "aws_apigatewayv2_api_mapping" "api_map" {
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.api_domain.id
  stage       = "$default"
}

