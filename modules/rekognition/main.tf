# 1. Kinesis Video Stream to receive the camera feed
resource "aws_kinesis_video_stream" "gate_stream" {
  name                    = "${var.project_name}-gate-stream-${var.environment}"
  data_retention_in_hours = 24 # Retain video for 24 hours
  tags                    = var.tags
}

# 2. SNS Topic for the Verification Lambda to publish detection results to
resource "aws_sns_topic" "plate_detections" {
  name = "${var.project_name}-plate-detections-${var.environment}"
  tags = var.tags
}

