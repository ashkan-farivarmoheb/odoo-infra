#!/bin/bash

# Set variables
BUCKET_NAME="keystores"
FILE_PATH="./jwt_keystore_${1}_v${2}.jks"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-}"
# IAM_USER="${IAM_USER:-YourUserName}"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
  echo "AWS CLI is not configured. Please configure it before running the script."
  exit 1
fi

# Step 1: Verify if the bucket exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "Bucket '$BUCKET_NAME' already exists."
else
  echo "Bucket '$BUCKET_NAME' does not exist. Creating it..."
  aws s3api create-bucket --bucket "$BUCKET_NAME" \
    --create-bucket-configuration
  echo "Bucket '$BUCKET_NAME' created successfully."
fi

# Step 2: Check if IAM user/role has necessary permissions
# echo "Validating IAM user permissions..."
# POLICY_CHECK=$(aws iam simulate-principal-policy \
#   --policy-source-arn "arn:aws:iam::$AWS_ACCOUNT_ID:user/$IAM_USER" \
#   --action-names "s3:PutObject" \
#   --resource-arns "arn:aws:s3:::$BUCKET_NAME/*")

# if echo "$POLICY_CHECK" | grep -q '"Decision": "allowed"'; then
#   echo "IAM user has necessary permissions."
# else
#   echo "IAM user does not have 's3:PutObject' permissions on $BUCKET_NAME. Fixing..."
#   aws iam put-user-policy --user-name "$IAM_USER" --policy-name "S3PutObjectPolicy" --policy-document '{
#     "Version": "2012-10-17",
#     "Statement": [
#       {
#         "Effect": "Allow",
#         "Action": "s3:PutObject",
#         "Resource": "arn:aws:s3:::'"$BUCKET_NAME"'/*"
#       }
#     ]
#   }'
#   echo "IAM policy updated successfully."
# fi

# Step 3: Upload the file to S3
if [ -f "$FILE_PATH" ]; then
  echo "Uploading $FILE_PATH to S3 bucket $BUCKET_NAME..."
  aws s3 cp "$FILE_PATH" "s3://$BUCKET_NAME/${1}"
  if [ $? -eq 0 ]; then
    echo "File uploaded successfully to s3://$BUCKET_NAME/${1}"
  else
    echo "Failed to upload the file. Please check the logs for details."
    exit 1
  fi
else
  echo "File $FILE_PATH does not exist. Please check the file path and try again."
  exit 1
fi
