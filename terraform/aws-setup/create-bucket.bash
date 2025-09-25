export UNIQUE_NAME=justin-udacity

#### Create Bucket cho Terraform state
  aws s3api create-bucket \
    --bucket terraform-state-$UNIQUE_NAME \
    --region us-east-2 \
    --create-bucket-configuration LocationConstraint=us-east-2

### Create Bucket cho AMI image
aws s3api create-bucket \
  --bucket ami-image-bucket-$UNIQUE_NAME \
  --region us-east-2 \
  --create-bucket-configuration LocationConstraint=us-east-2
