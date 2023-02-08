#!/bin/sh

bucket_name=ml-train1

python scripts/change_mode.py Testor
mvn clean install > /dev/null
tar --exclude='*.DS_Store' -zcvf testing.tar ./dataset/TestingDataset.csv ./target/MLTrain_Testor-1.0-SNAPSHOT.jar

cd ./infrastructure/instance/
export TF_VAR_access_key=$AWS_ACCESS_KEY_ID
export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY
export TF_VAR_region=$AWS_REGION
terraform init > /dev/null
terraform plan > /dev/null
terraform apply --auto-approve
cd ../../