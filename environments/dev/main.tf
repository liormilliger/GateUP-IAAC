# Configure the Terraform settings, including the required version and backend.
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configure the S3 backend for remote state storage.
  # This uses your existing S3 bucket.
  backend "s3" {
    bucket         = "liorm-gateup"
    key            = "tf-state/gatekeeper/dev/terraform.tfstate"
    region         = "us-east-1" # Please change this to the region where your bucket exists
    dynamodb_table = "terraform-state-locks" # The name of the DynamoDB table for state locking
    encrypt        = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Define common tags to apply to all resources, making them easier to manage.
locals {
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Call the VPC module to create our network infrastructure.
module "vpc" {
  source = "../../modules/vpc"

  vpc_name = var.vpc_name
  tags     = local.tags
}

# Call the Database module to create our DynamoDB tables.
module "database" {
  source = "../../modules/database"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.tags
}

# Call the IAM module to create the necessary role for our Lambda function.
module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.tags

  # Pass the ARNs from the database module to the IAM module to grant permissions.
  dynamodb_table_arns = [
    module.database.residents_table_arn,
    module.database.guests_table_arn,
    module.database.logs_table_arn,
    module.database.trespassing_table_arn
  ]
}
