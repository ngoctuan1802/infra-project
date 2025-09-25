region      = "us-east-2"
project     = "myproject"
environment = "dev"

vpc_cidr             = "10.100.0.0/16"
public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24"]
private_subnet_cidrs = ["10.100.11.0/24", "10.100.12.0/24"]

ami           = "ami-0abcdef1234567890"
instance_type = "t3.micro"
key_name      = "my-keypair"
