# Create buckets
cd ./infrastructure/buckets/
terraform init > /dev/null
terraform plan > /dev/null
terraform apply --auto-approve
echo "Buckets created"
cd ../../

# Copy the files to a temp folder, zip the folder up
# Upload the zip to S3 and delete the temp folder.

# mkdir lambda_files 
# cp ./{classes/ManageS3.py,lambda/*} ./lambda_files
# cd ./lambda_files/
# zip -r9 lambda_files.zip * > /dev/null
# cp ../scripts/s3lambda.sh ./

# Uploads the code to S3 bucket: s2quest.
# sh ./s3lambda.sh
# cd ../
# rm -r ./lambda_files

# Proceed with infrastructure creation.
sh ./scripts/TF_Script.sh