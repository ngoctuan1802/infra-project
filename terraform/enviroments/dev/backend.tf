terraform {
  backend "s3" {
    bucket = "udacity-sre-terraform-testing" # Replace it with your S3 bucket name
    key    = "terraform/terraform.tfstate"
    region = "us-east-2" # Update to your desired region
  }
}
