export AWS_ACCESS_KEY_ID=AKIARU3U5ZIE74DSFQGN
export AWS_SECRET_ACCESS_KEY=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
export File_Name=./lambda_function.zip

#!/bin/sh

# Exit immediately
set -e

# 1. Configure

AWS_REGION="us-east-1"
# configure aa profile and save the credentials to that profile.
# >> /dev/null redirects standard output (stdout) to /dev/null, which discards it.
# 2>&1 redirects standard error (2) to standard output (1),
# which then discards it as well since standard output has already been redirected.
# & indicates a file descriptor.
# There are usually 3 file descriptors - standard input, output, and error.
aws configure --profile ml-spark-aws <<-EOF > /dev/null 2>&1
$AWS_ACCESS_KEY_ID
$AWS_SECRET_ACCESS_KEY
$AWS_REGION
text
EOF

# 2. Sync

# Use the profile to connect to the s3 bucket
aws s3 cp s3://ml-train1/$1/ ./ --recursive \
              --profile ml-spark-aws \
              --no-progress

# aws s3 cp s3://ml-train1/dataset/ ~/ --recursive
# aws s3 cp s3://ml-train1/MLTrain_Trainer-1.0-SNAPSHOT.jar ~/MLTrain_Trainer-1.0-SNAPSHOT.jar


# 3. Unset

# Unset the variables.
aws configure --profile ml-spark-aws <<-EOF > /dev/null 2>&1
null
null
null
text
EOF