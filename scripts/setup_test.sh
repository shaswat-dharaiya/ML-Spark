#!/bin/sh

# python scripts/decide_mode.py Testor
# mvn clean install
# tar --exclude='*.DS_Store' -zcvf testing.tar ./dataset/TestingDataset.csv ./target/MLTrain_Testor-1.0-SNAPSHOT.jar

cd ./infrastructure/instance/
echo $AWS_ACCESS_KEY_ID
terraform init > /dev/null
terraform plan > /dev/null
terraform apply --auto-approve
cd ../../