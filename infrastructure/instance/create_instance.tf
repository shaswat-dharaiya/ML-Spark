variable "access_key" {}
variable "region" {}
variable "secret_key" {}
variable "key"{
  default = "ml_spark"
}

variable "security_group_id" {}

provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
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
  key_name                    = "${var.key}"
  vpc_security_group_ids = ["${var.security_group_id}"]


  tags = {
    Name = "ML-User"
  }

  provisioner "file" {
    source      = "../../testing.tar"
    destination = "/home/ubuntu/testing.tar"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("../../${var.key}.cer")}"
      host        = "${self.public_dns}"
    }
  }

  provisioner "file" {
    source      = "../../scripts/testing_script.sh"
    destination = "/home/ubuntu/testing_script.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("../../${var.key}.cer")}"
      host        = "${self.public_dns}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/testing_script.sh",
      "/home/ubuntu/testing_script.sh ${var.access_key} ${var.secret_key} ${var.region}",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("../../${var.key}.cer")}"
      host        = "${self.public_dns}"
    }
  }
}

