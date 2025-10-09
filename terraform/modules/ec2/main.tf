# This resource block defines an AWS EC2 instance.
# The local name "web" is used to refer to this instance within the Terraform configuration.
resource "aws_instance" "web" {
  ami           = var.aws_ami
  instance_type = "t3.micro"
  key_name      = "udacity"                      # key_name specifies the name of the SSH key pair to use for accessing the instance.
  subnet_id     = var.public_subnet_ids[0]       # set subnet_id to the first public subnet from the input variable.

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id,      # Attaches the custom security group defined below.
    data.aws_security_group.default.id # Attaches the default security group for the VPC, retrieved by a data source.
  ]
  tags = {
    Name = "ubuntu"
  }
}

# This data source retrieves information about the default security group for a specific VPC.
data "aws_security_group" "default" {
  # Specifies the name of the security group to find.
  name = "default"
  # Specifies the VPC ID in which to search for the security group.
  vpc_id = var.vpc_id
}

# This resource block defines a new security group named "ec2_sg".
resource "aws_security_group" "ec2_sg" {
  # The name of the security group.
  name = "ec2_sg"
  # The ID of the VPC where this security group will be created.
  vpc_id = var.vpc_id

  # Ingress rules define the allowed inbound traffic to the EC2 instance.
  # This rule allows inbound HTTP traffic on port 80 from any IP address.
  ingress {
    description = "web port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # This rule allows inbound SSH traffic on port 22 from any IP address for remote management.
  ingress {
    description = "ssh port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # This rule allows inbound traffic on port 9100, commonly used for monitoring systems
  # like Prometheus Node Exporter, from any IP address.
  ingress {
    description = "monitoring"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rules define the allowed outbound traffic from the EC2 instance.
  # This rule allows all outbound traffic on all ports and protocols to any destination.
  # This is a common default setting.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" signifies all protocols.
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Assigns a "Name" tag to the security group for easy identification in the AWS console.
  tags = {
    Name = "ec2_sg"
  }
}
