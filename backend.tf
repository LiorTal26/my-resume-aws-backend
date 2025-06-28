terraform {
  backend "s3" {
    bucket = "my-resume-tf-state-ilcentral1"
    key    = "backend/terraform.tfstate" # any path inside the bucket
    region = "il-central-1"

    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
