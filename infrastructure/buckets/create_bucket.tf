# Acccess the user's credentials
locals {
  instances = csvdecode(file("../user/private_key.csv"))
}

variable "bucket_name"{}

provider "aws" {
  access_key=tolist(local.instances)[0]["Access key ID"]
  secret_key=tolist(local.instances)[0]["Secret access key"]
  region = "us-east-1"
}

# ------------------------------------------------------

# Create a publicly available S3 Bucket that will store the Datasetfrom Step 1
resource "aws_s3_bucket" "ml_bucket" {
    bucket = "${var.bucket_name}"
}