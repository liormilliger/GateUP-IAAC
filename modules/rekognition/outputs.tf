output "kinesis_video_stream_arn" {
  description = "The ARN of the Kinesis Video Stream."
  value       = aws_kinesis_video_stream.gate_stream.arn
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for plate detections."
  value       = aws_sns_topic.plate_detections.arn
}
