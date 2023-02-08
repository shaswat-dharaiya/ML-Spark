# # Acccess the user's credentials
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

data "aws_iam_role" "iam_emr_service_role" {
  name               = "ml_user_role"
}

resource "aws_iam_instance_profile" "emr_profile" {
  name = "emr_profile"
  role = data.aws_iam_role.iam_emr_service_role.name
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

resource "aws_emr_cluster" "cluster" {
  name          = "ML-Spark"
  release_label = "emr-5.36.0"
  applications  = ["Spark"]
  log_uri = "s3://ml-train1/"

  keep_job_flow_alive_when_no_steps = false
  termination_protection = false

  auto_termination_policy {
    idle_timeout = 200
  }
  
  master_instance_group {
    instance_type = "m3.xlarge"
  }


  tags = {
    name     = "ML-Spark"
  }

  core_instance_group {
    instance_type = "m3.xlarge"
    instance_count = 1

    ebs_config {
      size                 = "10"
      type                 = "standard"
      volumes_per_instance = 1
    }
  }

  ec2_attributes {
    emr_managed_master_security_group = aws_security_group.main.id
    emr_managed_slave_security_group  = aws_security_group.main.id
    instance_profile                  = aws_iam_instance_profile.emr_profile.arn
    key_name                          = "ml_spark"
  }

  service_role = data.aws_iam_role.iam_emr_service_role.arn

# 1st boostrap get's executed
  bootstrap_action{
    name = "ENV Setup"
    path = "s3://ml-train1/scripts/user_script_ec2.sh"
  }

# Then steps get executed.
  step {
    action_on_failure = "CONTINUE"
    name   = "Train the model"
    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["bash","-c","aws s3 cp s3://ml-train1/scripts/spark_steps.sh /home/hadoop; chmod u+x /home/hadoop/spark_steps.sh; cd /home/hadoop; ./spark_steps.sh"] 
    }
  }

}