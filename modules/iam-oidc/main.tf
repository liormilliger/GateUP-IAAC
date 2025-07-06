variable "trusted_github_repos" {
  description = "A list of GitHub repositories (e.g., ['user/repo1', 'user/repo2']) to trust."
  type        = list(string)
}

# 1. Get the OIDC provider information from GitHub
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
            # This condition now restricts access to a list of specified repositories.
            "token.actions.githubusercontent.com:sub" = [
              for repo in var.trusted_github_repos : "repo:${repo}:*"
            ]
          }
        }
      }
    ]
  })
}

# 3. Attach the AdministratorAccess policy to the role
resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
