locals {
  instances = csvdecode(file("../user/private_key.csv"))
}

provider "aws" {
  access_key = tolist(local.instances)[0]["Access key ID"]
  secret_key = tolist(local.instances)[0]["Secret access key"]
  region = "us-east-1"
}

# Access the IAM Role created earlier
data "aws_iam_role" "ml_user" {
  name             = "ml_user_role"
}

# -----------------------STEP 4.1-----------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  associate_public_ip_address = true
  availability_zone           = "us-east-1b"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = "ml_spark"
  vpc_security_group_ids = [aws_security_group.main.id]


  tags = {
    Name = "ML-User"
  }

  provisioner "file" {
    source      = "../../testing.tar"
    destination = "/home/ubuntu/testing.tar"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("../../ml_spark.cer")}"
      host        = "${self.public_dns}"
    }
  }

  provisioner "file" {
    source      = "../../scripts/testing_script.sh"
    destination = "/home/ubuntu/testing_script.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("../../ml_spark.cer")}"
      host        = "${self.public_dns}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/testing_script.sh",
      "/home/ubuntu/testing_script.sh args",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("../../ml_spark.cer")}"
      host        = "${self.public_dns}"
    }
  }
}

resource "aws_security_group" "main" {

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