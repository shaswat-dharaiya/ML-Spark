# Exit immediately
AWS_REGION="us-east-1"
aws configure --profile rearc-quest-aws <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

# Empty the buckets.
aws s3 rm s3://s2quest/ \
              --profile rearc-quest-aws \
              --recursive

aws s3 rm s3://s1quest/ \
              --profile rearc-quest-aws \
              --recursive


# Unset the variables.
aws configure --profile rearc-quest-aws <<-EOF > /dev/null 2>&1
null
null
null
text
EOF

# Delete the infrastructure.
cd ./infrastructure/pipeline/
terraform destroy --auto-approve
cd  ../buckets
terraform destroy --auto-approve