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