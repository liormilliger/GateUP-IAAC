variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-1" # You can change this to your preferred region
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "gatekeeper"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}