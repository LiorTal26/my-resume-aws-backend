#  Provider alias for us-east-1 required by CloudFront
provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

# Certificates
# us-east-1  =>  CloudFront alias  (lior-cv.tal-handassa.com)
resource "aws_acm_certificate" "site_cert" {
  provider          = aws.useast1
  domain_name       = "${var.site_sub}.${var.domain_root}"
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

# il-central-1  →  API custom domain  (api.lior-cv.tal-handassa.com)
resource "aws_acm_certificate" "api_cert" {
  domain_name       = "${var.api_sub}.${var.domain_root}"
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

# 2. DNS validation records (one per cert)
data "aws_route53_zone" "root" {
  name         = var.domain_root # tal-handassa.com
  private_zone = false
}

# Pull the single DVO object out of each set
locals {
  site_dvo = one(aws_acm_certificate.site_cert.domain_validation_options)
  api_dvo  = one(aws_acm_certificate.api_cert.domain_validation_options)
}

# ── site_cert CNAME ──────────────────────────────────────────────
resource "aws_route53_record" "site_cert_validation" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = local.site_dvo.resource_record_name
  type    = local.site_dvo.resource_record_type
  ttl     = 300
  records = [local.site_dvo.resource_record_value]
}

# ── api_cert CNAME ───────────────────────────────────────────────
resource "aws_route53_record" "api_cert_validation" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = local.api_dvo.resource_record_name
  type    = local.api_dvo.resource_record_type
  ttl     = 300
  records = [local.api_dvo.resource_record_value]
}


# Certificate validations
resource "aws_acm_certificate_validation" "site_validate" {
  provider                = aws.useast1
  certificate_arn         = aws_acm_certificate.site_cert.arn
  validation_record_fqdns = [aws_route53_record.site_cert_validation.fqdn]
}

resource "aws_acm_certificate_validation" "api_validate" {
  certificate_arn         = aws_acm_certificate.api_cert.arn
  validation_record_fqdns = [aws_route53_record.api_cert_validation.fqdn]
}
