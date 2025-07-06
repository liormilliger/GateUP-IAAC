output "vpc_id" {
  description = "The ID of the VPC created."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

# --- NEW: Output the ARN of the new role ---
output "github_actions_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions to assume."
  value       = module.iam_oidc.role_arn
}