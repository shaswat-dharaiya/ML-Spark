#!/bin/sh

bucket_name=ml-train1 

# Delete the infrastructure.
cd ./infrastructure/cluster
export TF_VAR_access_key=$AWS_ACCESS_KEY_ID
export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
export TF_VAR_region=$AWS_REGION

export TF_VAR_bucket_name=$bucket_name
export TF_VAR_role=$IAM_ROLE
export TF_VAR_security_group_id=$SEC_GRP
export TF_VAR_profile=$IAM_ROLE_PROF
terraform destroy --auto-approve

cd ./../instance/
export TF_VAR_access_key=$AWS_ACCESS_KEY_ID
export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
export TF_VAR_region=$AWS_REGION
terraform destroy --auto-approve