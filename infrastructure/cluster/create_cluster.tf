variable "access_key" {}
variable "secret_key" {}
variable "region" {}

variable "bucket_name"{}
variable "role"{}
variable "security_group_id" {}
variable "profile" {}

provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

# Access the IAM Role created earlier

# ------------------------------------------------------

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
    emr_managed_master_security_group = var.security_group_id
    emr_managed_slave_security_group  = var.security_group_id
    instance_profile                  = var.profile 
    key_name                          = "ml_spark"
  }

  service_role = var.role
# 1st boostrap get's executeds
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