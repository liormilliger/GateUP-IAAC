output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "A list of IDs for the public subnets."
  value       = module.vpc.public_subnets
}
