# Create a new IAM User and attach the required policies & keys.
cd ./infrastructure/user/
terraform init > /dev/null
# terraform destroy --auto-approve 
export TF_VAR_access_key=$AWS_ACCESS_KEY_ID_ROOT
export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY_ROOT
export TF_VAR_region=$AWS_REGION
terraform plan > /dev/null
terraform apply --auto-approve 
echo "User created, policies attached."