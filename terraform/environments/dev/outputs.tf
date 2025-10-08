output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ec2_public_ips" {
  value = module.project_ec2.public_ips
}

output "eks_endpoint" {
  value = module.project_eks.cluster_endpoint
}
