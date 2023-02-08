# This script destroy the IAM User.
cd  ./infrastructure/user
export TF_VAR_access_key=$AWS_ACCESS_KEY_ID_ROOT
export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY_ROOT
export TF_VAR_region=$AWS_REGION

terraform destroy --auto-approve

unset IAM_USER AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY IAM_ROLE IAM_ROLE_PROF SEC_GRP

source ~/.zshrc