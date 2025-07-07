variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "kinesis_video_stream_arn" {
  description = "The ARN of the Kinesis Video Stream to process."
  type        = string
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic to publish results to."
  type        = string
}

variable "dynamodb_table_arns" {
  description = "A list of DynamoDB table ARNs that the role needs access to."
  type        = list(string)
  default     = []
}
