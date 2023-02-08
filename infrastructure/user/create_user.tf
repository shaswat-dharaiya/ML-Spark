variable "access_key" {}
variable "secret_key" {}
variable "region" {}

provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}


# ------------------------------------------------------

# Create a new IAM User
resource "aws_iam_user" "user" {
  name = "ml-user"
}

# Create the user's key
resource "aws_iam_access_key" "user_key" {
  user    = "${aws_iam_user.user.name}"
  depends_on = [aws_iam_user.user]
}

# ------------------------------------------------------

# Attach the required policies
resource "aws_iam_user_policy_attachment" "attach-user" {
  user       = "${aws_iam_user.user.name}"
  for_each = toset([
    "arn:aws:iam::aws:policy/IAMFullAccess", 
    "arn:aws:iam::aws:policy/AmazonS3FullAccess", 
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonEMRFullAccessPolicy_v2",
    "arn:aws:iam::aws:policy/AmazonElasticMapReduceFullAccess"
  ])
  policy_arn = each.value   
}

# ------------------------------------------------------

# Get the existing policy for required for EC2 function service
data "aws_iam_policy_document" "AWSEC2TrustPolicy" {
  statement {
    actions    = ["sts:AssumeRole"]
    effect     = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com","elasticmapreduce.amazonaws.com"]
    }
  }
}

# Create a new IAM Policy and attach the EC2 & EMR function service to it.
resource "aws_iam_role" "iam_emr_service_role" {
  name               = "ml_user_role"
  assume_role_policy = "${data.aws_iam_policy_document.AWSEC2TrustPolicy.json}"
  depends_on = [
    aws_iam_access_key.user_key
  ]
}

# Add additional policies to newly created role.
resource "aws_iam_role_policy_attachment" "srd_policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonS3FullAccess", 
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeSchemasFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeSchedulerFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AmazonEMRFullAccessPolicy_v2",
    "arn:aws:iam::aws:policy/AmazonElasticMapReduceFullAccess"
  ])
  role       = "${aws_iam_role.iam_emr_service_role.name}"
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "emr_profile" {
  name = "emr_profile"
  role = aws_iam_role.iam_emr_service_role.name
}

resource "aws_security_group" "main" {
  # tags = {
  #   Name = "EMR Common"
  # }

  name = "emr_test_instance"
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  ingress                = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    }
  ]
}