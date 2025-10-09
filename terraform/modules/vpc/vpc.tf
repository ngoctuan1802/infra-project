resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      "Name" = format("%s", var.name) # VPC name tag base on name 
    }
  )
}
### PRIVATE SUBNET ###
resource "aws_subnet" "private" {
  count             = length(var.azs) > 0 ? length(var.azs) : 0 # Create private subnets base on number of AZs provided
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index] # Use provided CIDRs
  availability_zone = element(var.azs, count.index)         # Assign each subnet to a different AZ

  tags = merge(
    {
      "Name" = format(
        "%s-private-%s",
        var.name,
        element(var.azs, count.index),
      )
    },
    var.private_subnet_tags
  ) # Merge user defined tags with default Name tags example: my-vpc-private-us-east-1a
}
#### Public SUBNET ########
resource "aws_subnet" "public" {
  count = length(var.azs) > 0 ? length(var.azs) : 0

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index] # Use provided CIDRs
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    {
      "Name" = format(
        "%s-public-%s",
        var.name,
        element(var.azs, count.index),
      )
    },
    var.public_subnet_tags
  )
}

