#!/bin/bash

# Đặt quyền thực thi: chmod +x restore-cp-ami-fixed.sh
# Chạy script: export UNIQUE_NAME="your-unique-name"
# ./restore-cp-ami-fixed.sh

# Kiểm tra biến UNIQUE_NAME
if [ -z "$UNIQUE_NAME" ]; then
    echo "Error: UNIQUE_NAME environment variable is not set"
    exit 1
fi

echo "Starting AMI restore process..."

# Restore image từ bucket Udacity (ở region us-east-1)
echo "Restoring AMI from S3 bucket..."
AMI_ID=$(aws ec2 create-restore-image-task \
  --object-key ami-08dff635fabae32e7.bin \
  --bucket udacity-srend \
  --name "udacity-ami-restore-$UNIQUE_NAME" \
  --region us-east-1 \
  --query 'ImageId' \
  --output text)

if [ -z "$AMI_ID" ] || [ "$AMI_ID" == "None" ]; then
    echo "Error: Failed to create restore image task"
    exit 1
fi

echo "Restored AMI ID in us-east-1: $AMI_ID"

# Đợi AMI hoàn thành quá trình restore
echo "Waiting for AMI to be available..."
aws ec2 wait image-available --region us-east-1 --image-ids $AMI_ID

# Kiểm tra trạng thái AMI
AMI_STATE=$(aws ec2 describe-images \
  --region us-east-1 \
  --image-ids $AMI_ID \
  --query 'Images[0].State' \
  --output text)

echo "AMI State: $AMI_STATE"

if [ "$AMI_STATE" != "available" ]; then
    echo "Error: AMI is not available yet. Current state: $AMI_STATE"
    echo "Please wait and try again later, or check the restore task status"
    exit 1
fi

# Copy AMI từ us-east-1 sang us-east-2
echo "Copying AMI from us-east-1 to us-east-2..."
NEW_AMI_ID=$(aws ec2 copy-image \
  --source-image-id $AMI_ID \
  --source-region us-east-1 \
  --region us-east-2 \
  --name "udacity-$UNIQUE_NAME" \
  --query 'ImageId' \
  --output text)

if [ -z "$NEW_AMI_ID" ] || [ "$NEW_AMI_ID" == "None" ]; then
    echo "Error: Failed to copy AMI to us-east-2"
    exit 1
fi

echo "Copied AMI ID in us-east-2: $NEW_AMI_ID"

# Đợi AMI được copy hoàn thành (optional)
echo "Waiting for copied AMI to be available in us-east-2..."
aws ec2 wait image-available --region us-east-2 --image-ids $NEW_AMI_ID

echo "AMI copy process completed successfully!"
echo "Source AMI (us-east-1): $AMI_ID"
echo "Destination AMI (us-east-2): $NEW_AMI_ID"