# Creates the infrastructure
cd ./infrastructure/pipeline/
terraform init > /dev/null
terraform plan > /dev/null
terraform apply --auto-approve 