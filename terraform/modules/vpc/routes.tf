###################
# Internet Gateway
###################

# Creates an Internet Gateway (IGW) to allow communication between the VPC and the internet.
# An IGW is a horizontally scaled, redundant, and highly available VPC component.
# The `count` ensures this resource is only created if at least one availability zone is specified.
resource "aws_internet_gateway" "this" {
  count  = length(var.azs) > 0 ? 1 : 0 # Create only if AZs are provided
  vpc_id = aws_vpc.this.id             # Attach IGW to the VPC
  tags = merge(
    {
      "Name" = format("%s", var.name) # example: my-vpc
    }
  )
}

# Creates a single route table for all public subnets.
# This table will contain a route to the Internet Gateway, making any associated subnets "public".
# The `count` ensures this resource is only created if at least one availability zone is specified.
resource "aws_route_table" "public" {
  count  = length(var.azs) > 0 ? 1 : 0 # Create only if AZs are provided
  vpc_id = aws_vpc.this.id             # Associate route table with the VPC
  tags = merge(
    {
      "Name" = format("%s-public", var.name) # example: my-vpc-public
    }
  )
}

# Creates a route in the public route table that directs all outbound internet traffic (0.0.0.0/0)
# to the Internet Gateway created above. Only one such route is needed for the public route table.
resource "aws_route" "public_internet_gateway" {
  count                  = length(var.azs) > 0 ? 1 : 0 # create enough number of routes based on number of AZs provided
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  # Specifies a timeout for the creation of this route.
  timeouts {
    create = "5m"
  }
}

##############
# NAT Gateway
##############

locals {
  # Defines the number of NAT Gateways to create. A single NAT Gateway is a common pattern for cost-saving,
  # but it is a single point of failure. For high availability, you would set this to the number of AZs.
  nat_gateway_count = 1
}

# Creates an Elastic IP (EIP) address for each NAT Gateway.
# NAT Gateways require a static public IP to function.
resource "aws_eip" "nat" {
  count = local.nat_gateway_count

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(var.azs, count.index),
      )
    }
  )
}

# Creates a Network Address Translation (NAT) Gateway.
# This allows instances in private subnets to initiate outbound traffic to the internet
# (e.g., for software updates) while remaining inaccessible from the internet.
resource "aws_nat_gateway" "this" {
  count         = local.nat_gateway_count
  allocation_id = aws_eip.nat[count.index].id # Associates one of the EIPs created above with this NAT Gateway.

  # The NAT Gateway must reside in a public subnet to have a route to the Internet Gateway.
  subnet_id = element(
    aws_subnet.public.*.id,
    count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(var.azs, count.index),
      ) # example: my-vpc-us-east-1a
    }
  )

  # Explicitly state that the NAT Gateway depends on the Internet Gateway.
  # This ensures the IGW is created and attached to the VPC before the NAT Gateway is created.
  depends_on = [aws_internet_gateway.this]
}

# Creates a separate route table for each private subnet (one per AZ).
# This allows each AZ's private subnet to have its own routing rules.
resource "aws_route_table" "private" {
  count  = length(var.azs) > 0 ? length(var.azs) : 0
  vpc_id = aws_vpc.this.id # Associate route table with the VPC
  tags = merge(
    {
      "Name" = format("%s-private-%s", var.name, element(var.azs, count.index),
      )
    }
  )
  # The lifecycle block prevents Terraform from undoing changes made outside of this configuration.
  # `propagating_vgws` is ignored because a Virtual Private Gateway (VGW) can dynamically
  # add routes to this table, and we don't want Terraform to remove them on the next apply.
  lifecycle {
    ignore_changes = [propagating_vgws]
  }
}

# Creates a route in each private route table that directs all outbound internet traffic (0.0.0.0/0)
# to the NAT Gateway. This enables instances in the private subnets to access the internet.
resource "aws_route" "private_nat_gateway" {
  count                  = length(var.azs)
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"

  # All private route tables point to the single NAT Gateway.
  # If using multiple NAT Gateways (one per AZ), this would be `aws_nat_gateway.this[count.index].id`.
  nat_gateway_id = aws_nat_gateway.this[0].id

  # Specifies a timeout for the creation of this route.
  timeouts {
    create = "5m"
  }
}

# Route table association
##########################

# Associates each public subnet with the single public route table.
# This makes all subnets in the `aws_subnet.public` list public.
resource "aws_route_table_association" "public" {
  count = length(var.azs) > 0 ? length(var.azs) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

# Associates each private subnet with its corresponding private route table.
# This establishes a one-to-one mapping between a private subnet and a private route table.
resource "aws_route_table_association" "private" {
  count = length(var.azs) > 0 ? length(var.azs) : 0

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}
