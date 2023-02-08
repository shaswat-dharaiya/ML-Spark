# Create a new IAM User and attach the required policies & keys.
cd ./infrastructure/user/
terraform init > /dev/null
# terraform destroy --auto-approve 

export TF_VAR_access_key=$AWS_ACCESS_KEY_ID_ROOT
export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY_ROOT
export TF_VAR_region=$AWS_REGION
terraform plan > /dev/null
terraform apply --auto-approve 

echo export IAM_USER=$(terraform output user) | tr -d '"' >> ~/.zshrc
echo export AWS_ACCESS_KEY_ID=$(terraform output key) | tr -d '"' >> ~/.zshrc
echo export AWS_SECRET_ACCESS_KEY=$(terraform output secret) | tr -d '"' >> ~/.zshrc
echo export IAM_ROLE=$(terraform output role) | tr -d '"' >> ~/.zshrc
echo export IAM_ROLE_PROF=$(terraform output profile) | tr -d '"' >> ~/.zshrc
echo export SEC_GRP=$(terraform output asg) | tr -d '"' >> ~/.zshrc

source ~/.zshrc

echo "User created, policies attached."