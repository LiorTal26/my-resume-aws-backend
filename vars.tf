variable "aws_region" { default = "il-central-1" }                   
variable "aws_s3_bucket_name" { default = "my-resume-site-lior-il" } # static bucket
variable "ddb_table_name" { default = "resume_visitors" }            # DynamoDB table
variable "lambda_name" { default = "resume-counter" }                # Lambda fn



variable "domain_root" {
  description = "Root DNS zone (registered domain)"
  type        = string
  default     = "tal-handassa.com"
}

variable "site_sub" {
  description = "Sub-domain for the résumé / CloudFront site"
  type        = string
  default     = "lior-cv"
}

variable "api_sub" {
  description = "Sub-domain for the API custom domain"
  type        = string
  default     = "api.lior-cv"
}
