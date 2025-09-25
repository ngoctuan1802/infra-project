variable "region" { default = "us-east-2" }
variable "project" { default = "myproject" }
variable "environment" { default = "dev" }

# VPC / Subnets
variable "vpc_cidr" { default = "10.100.0.0/16" }
variable "public_subnet_cidrs" { default = ["10.100.1.0/24", "10.100.2.0/24"] }
variable "private_subnet_cidrs" { default = ["10.100.11.0/24", "10.100.12.0/24"] }
variable "azs" { default = ["us-east-2a", "us-east-2b"] }

# EC2
variable "ami" { default = "ami-0abcdef1234567890" } # replace with real AMI
variable "instance_type" { default = "t3.micro" }
variable "key_name" { default = "" }
