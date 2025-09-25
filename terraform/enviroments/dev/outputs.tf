output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ec2_public_ips" {
  value = module.ec2.public_ips
}

output "eks_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cloudwatch_log_group" {
  value = module.cloudwatch.log_group_name
}
