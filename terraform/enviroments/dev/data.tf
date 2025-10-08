# To get information about the current AWS account and region
data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.project_eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.project_eks.cluster_name
}
