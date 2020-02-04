provider "aws" {
  region  = var.default_aws_region
  version = "~> 2.41"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "${var.my_bucket}"
  acl    = "private"

  tags = {
    "project" = "great_expectations_lambda"
  }
}
