## PROJECT 
resource "kubernetes_namespace" "udacity" {
  metadata {
    name = local.name
  }
  depends_on = [
    module.project_eks
  ]
}

## LOCAL VIRIABLES

locals {
  account_id = data.aws_caller_identity.current.account_id

  name   = "udacity"
  region = "us-east-2"
  tags = {
    Name      = local.name
    Terraform = "true"
  }
}


#### VPC

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.100.0.0/16"

  account_owner = local.name
  name          = "${local.name}-project"
  azs           = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
}

### EC2 WEB SERVER

module "project_ec2" {
  source             = "./modules/ec2"
  name               = local.name
  account            = data.aws_caller_identity.current.account_id
  aws_ami            = "ami-01040813c3969933e"
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
}

### EKS CLUSTER

provider "kubernetes" {
  config_path            = "~/.kube/config"
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster" "cluster" {
  name = module.project_eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.project_eks.cluster_id
}

module "project_eks" {
  source             = "./modules/eks"
  name               = local.name
  account            = data.aws_caller_identity.current.account_id
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
}
