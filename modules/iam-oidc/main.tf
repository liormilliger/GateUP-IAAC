# modules/iam-oidc/main.tf

# This module creates the IAM Role that GitHub Actions will assume to run Terraform.

# 1. Get the OIDC provider information from GitHub
# This will now succeed because you have manually created the provider in your AWS account.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# 2. Create the IAM Role
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-terraform-role"

  # This policy allows principals from GitHub's OIDC provider to assume this role.
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn
        },
        Action    = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            # This condition restricts access to only your repository.
            # IMPORTANT: Replace 'liormilliger/GateUP-IAAC' with your GitHub username and repo name.
            "token.actions.githubusercontent.com:sub" = "repo:liormilliger/GateUP-IAAC:*"
          }
        }
      }
    ]
  })
}

# 3. Attach the AdministratorAccess policy to the role
# This is the modern replacement for the deprecated 'managed_policy_arns' argument.
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
