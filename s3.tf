provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "static_site" {
  bucket        = var.aws_s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "owner" {
  bucket = aws_s3_bucket.static_site.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket                  = aws_s3_bucket.static_site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "read_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.owner,
    aws_s3_bucket_public_access_block.public
  ]
  bucket = aws_s3_bucket.static_site.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_site.id
  index_document { suffix = "index.html" }
  error_document { key = "index.html" }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.static_site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.static_site.arn}/*"
    }]
  })
}

# uncomment this block to upload static files to the S3 bucket without the frontend module

# resource "aws_s3_object" "site_files" {
#   for_each = {
#     for f in fileset("${path.module}/static", "**") :
#     f => f
#     if !endswith(f, ".tmpl") # <-- skip template files
#   }

#   bucket = aws_s3_bucket.static_site.id
#   key    = each.value
#   source = "${path.module}/static/${each.value}"
#   etag   = filemd5("${path.module}/static/${each.value}")

#   content_type = lookup(
#     {
#       html = "text/html"
#       css  = "text/css"
#       js   = "application/javascript"
#       png  = "image/png"
#       jpg  = "image/jpeg"
#       jpeg = "image/jpeg"
#       svg  = "image/svg+xml"
#       ico  = "image/x-icon"
#     },
#     lower(element(split(".", each.value), length(split(".", each.value)) - 1)),
#     "application/octet-stream"
#   )

#   # 1-minute TTL so CloudFront auto-refreshes (no manual invalidations)
#   cache_control = "max-age=60, must-revalidate"
# }
