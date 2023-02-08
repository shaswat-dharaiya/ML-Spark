#!/bin/sh

bucket_name=ml-train1 

aws configure --profile rearc-quest-aws <<-EOF > /dev/null 2>&1
$AWS_ACCESS_KEY_ID
$AWS_SECRET_ACCESS_KEY
$AWS_REGION
text
EOF

# Empty the buckets.
aws s3 rm s3://$bucket_name/ \
              --profile rearc-quest-aws \
              --recursive

cd ./infrastructure/buckets/

export TF_VAR_access_key=$AWS_ACCESS_KEY_ID
export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
export TF_VAR_region=$AWS_REGION
export TF_VAR_bucket_name=$bucket_name
terraform destroy --auto-approve

# Delete the infrastructure.
cd ../cluster
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


# cd  ../buckets

# bucket_name=ml-train1
# terraform destroy -var="bucket_name=$bucket_name" --auto-approve