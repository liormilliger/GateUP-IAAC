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