#############################################################################
# Résumé  →  CloudFront  (lior-cv.tal-handassa.com)
#############################################################################
resource "aws_route53_record" "site_alias" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${var.site_sub}.${var.domain_root}"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# Optional IPv6 alias (delete if you don’t want it)
resource "aws_route53_record" "site_alias_ipv6" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${var.site_sub}.${var.domain_root}"
  type    = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

#############################################################################
# API  →  API Gateway custom domain  (api.lior-cv.tal-handassa.com)
#############################################################################
resource "aws_route53_record" "api_alias" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "${var.api_sub}.${var.domain_root}"
  type    = "A"
  alias {
    name                   = aws_apigatewayv2_domain_name.api_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
