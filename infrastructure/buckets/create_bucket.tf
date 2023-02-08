variable "access_key" {}
variable "bucket_name"{}
variable "secret_key" {}
variable "region" {}

provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# ------------------------------------------------------

# Create a publicly available S3 Bucket that will store the Datasetfrom Step 1
resource "aws_s3_bucket" "ml_bucket" {
    bucket = "${var.bucket_name}"
}