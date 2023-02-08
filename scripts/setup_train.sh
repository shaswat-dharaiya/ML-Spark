#!/bin/sh

set -e

bucket_name=ml-train1

AWS_ACCESS_KEY_ID=AKIARU3U5ZIE74DSFQGN
AWS_SECRET_ACCESS_KEY=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
AWS_REGION="us-east-1"

aws configure --profile ml-spark-aws <<-EOF > /dev/null 2>&1
$AWS_ACCESS_KEY_ID
$AWS_SECRET_ACCESS_KEY
$AWS_REGION
text
EOF

# Create buckets

cd ./infrastructure/buckets/

terraform init > /dev/null
terraform plan -var="bucket_name=$bucket_name" > /dev/null
terraform apply -var="bucket_name=$bucket_name" --auto-approve
echo "Buckets created"
cd ../../

aws s3 cp ./scripts/spark_steps.sh s3://$bucket_name/scripts/spark_steps.sh --profile ml-spark-aws
aws s3 cp ./scripts/user_script_ec2.sh s3://$bucket_name/scripts/user_script_ec2.sh --profile ml-spark-aws

python scripts/decide_mode.py Trainer
mvn clean install
tar --exclude='*.DS_Store' -zcvf training.tar ./dataset/TrainingDataset.csv ./dataset/ValidationDataset.csv ./target/MLTrain_Trainer-1.0-SNAPSHOT.jar

aws s3 cp ./training.tar s3://$bucket_name/training.tar --profile ml-spark-aws

cd ./infrastructure/cluster/
terraform init > /dev/null
terraform plan > /dev/null
terraform apply --auto-approve