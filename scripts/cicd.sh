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
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

# 2. Sync

# Use the profile to connect to the s3 bucket
aws s3 cp ${SOURCE_DIR} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
              --profile ml-spark-aws \
              --no-progress

# 3. Unset

# Unset the variables.
aws configure --profile ml-spark-aws <<-EOF > /dev/null 2>&1
null
null
null
text
EOF