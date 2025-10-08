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
  source               = "../../modules/vpc"
  cidr_block           = "10.100.0.0/16"
  name                 = "${local.name}-project"
  azs                  = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnet_cidrs = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
  public_subnet_cidrs  = ["10.100.101.0/24", "10.100.102.0/24", "10.100.103.0/24"]
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
}

### EC2 WEB SERVER

module "project_ec2" {
  source             = "../../modules/ec2"
  name               = local.name
  account            = data.aws_caller_identity.current.account_id
  aws_ami            = "ami-03f0e0a27c8814eaf"
  private_subnet_ids = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
}

### EKS CLUSTER

provider "kubernetes" {
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
  source             = "../../modules/eks"
  name               = local.name
  account            = data.aws_caller_identity.current.account_id
  private_subnet_ids = module.vpc.private_subnets
  vpc_id             = module.vpc.vpc_id
}
