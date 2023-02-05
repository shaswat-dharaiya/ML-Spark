# Acccess the user's credentials
locals {
  instances = csvdecode(file("../user/private_key.csv"))
}

variable "ml_bucket" {
  default = "s2quest"
}

provider "aws" {
  access_key=tolist(local.instances)[0]["Access key ID"]
  secret_key=tolist(local.instances)[0]["Secret access key"]
  region = "us-east-1"
}

# Access the IAM Role created earlier
data "aws_iam_role" "s3_quest_terraform" {
  name             = "automate_terraform"
}

# -----------------------STEP 4.1-----------------------

resource "aws_instance" "ml_ec2" {
  associate_public_ip_address = true
  availability_zone = "us-east-1"

}