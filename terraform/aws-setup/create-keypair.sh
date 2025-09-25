#!/bin/bash

# Đặt tên key pair (có thể thay đổi)
KEY_NAME="udacity"
KEY_FILE="udacity.pem"

# Tạo key pair
echo "Creating AWS EC2 Key Pair: $KEY_NAME"

aws ec2 create-key-pair \
  --key-name $KEY_NAME \
  --query 'KeyMaterial' \
  --output text > $KEY_FILE

# Kiểm tra và đặt quyền
if [ -f "$KEY_FILE" ]; then
    chmod 400 $KEY_FILE
    echo "✅ Key pair created: $KEY_FILE"
    echo "🔐 Permissions set to 400"
else
    echo "❌ Error creating key pair"
    exit 1
fi