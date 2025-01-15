#!/bin/bash

# Set variables
BUCKET_NAME="keystores-service"
FILE_PATH="./jwt_keystore_${1}_v${2}.jks"
REGION="${AWS_REGION:-}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-}"
PASSWORD="${PASSWORD:-}"
ALIAS="${ALIAS:-}"
OUTPUT_FILE="jwt_public_key_${1}_v${2}.pem"

# Get current date and time in milliseconds
TIMESTAMP=$(date +%s%3N)

# Step 1: Verify if the bucket exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "Bucket '$BUCKET_NAME' already exists."
else
  echo "Bucket '$BUCKET_NAME' does not exist. Creating it..."
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
  echo "Bucket '$BUCKET_NAME' created successfully."
fi

# Step 2: Upload the JKS file to S3
if [ -f "$FILE_PATH" ]; then
  echo "Uploading $FILE_PATH to S3 bucket $BUCKET_NAME..."
  aws s3 cp $FILE_PATH s3://$BUCKET_NAME/${1}/v${2}/$TIMESTAMP/
  if [ $? -eq 0 ]; then
    echo "File uploaded successfully to s3://$BUCKET_NAME/${1}/v${2}/$TIMESTAMP/"
  else
    echo "Failed to upload the file. Please check the logs for details."
    exit 1
  fi
else
  echo "File $FILE_PATH does not exist. Please check the file path and try again."
  exit 1
fi

# Step 3: Export the public key from the JKS file
keytool -export \
  -alias "$ALIAS" \
  -file "$OUTPUT_FILE" \
  -keystore "$FILE_PATH" \
  -storepass "$PASSWORD"

if [ $? -eq 0 ]; then
  echo "Public key exported successfully to $OUTPUT_FILE."
  echo "Uploading $OUTPUT_FILE to S3 bucket $BUCKET_NAME..."
  aws s3 cp $OUTPUT_FILE s3://$BUCKET_NAME/${1}/v${2}/$TIMESTAMP/
  if [ $? -eq 0 ]; then
    echo "Public key uploaded successfully to s3://$BUCKET_NAME/${1}/v${2}/$TIMESTAMP/"
  else
    echo "Failed to upload the public key. Please check the logs for details."
    exit 1
  fi
else
  echo "Failed to export the public key. Please check the logs for details."
  exit 1
fi