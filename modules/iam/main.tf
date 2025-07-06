# 1. IAM Role for Lambda
# This role allows the Lambda service to assume it.
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-lambda-exec-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# 2. IAM Policy for DynamoDB Access
# This policy grants specific permissions to the tables we created.
resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "${var.project_name}-dynamodb-access-policy-${var.environment}"
  description = "Policy to allow access to the project's DynamoDB tables."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Effect   = "Allow",
        Resource = var.dynamodb_table_arns
      }
    ]
  })
}

# 3. Attach Policies to the Role
# Attach the AWS-managed policy for basic Lambda execution (writing to CloudWatch Logs).
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach our custom DynamoDB access policy.
resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}
