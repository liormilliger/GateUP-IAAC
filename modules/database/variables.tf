variable "project_name" {
  description = "The name of the project to use as a prefix for resource names."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging)."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

output "residents_table_arn" {
  description = "The ARN of the Residents DynamoDB table."
  value       = aws_dynamodb_table.residents.arn
}

output "guests_table_arn" {
  description = "The ARN of the Guests DynamoDB table."
  value       = aws_dynamodb_table.guests.arn
}

output "logs_table_arn" {
  description = "The ARN of the Logs DynamoDB table."
  value       = aws_dynamodb_table.logs.arn
}

output "trespassing_table_arn" {
  description = "The ARN of the Trespassing DynamoDB table."
  value       = aws_dynamodb_table.trespassing.arn
}