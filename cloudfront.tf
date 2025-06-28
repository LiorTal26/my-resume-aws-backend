locals {
  # REST endpoint (valid for S3 origin + OAC)
  s3_origin_domain = aws_s3_bucket.static_site.bucket_regional_domain_name
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "static-site-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

 
  aliases = ["${var.site_sub}.${var.domain_root}"] # lior-cv.tal-handassa.com

  origin {
    domain_name = local.s3_origin_domain 
    origin_id   = "s3StaticSite"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3StaticSite"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl     = 0
    default_ttl = 60
    max_ttl     = 300
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.site_cert.arn # us-east-1 cert
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [
    aws_s3_bucket_policy.public_read
  ]
}
