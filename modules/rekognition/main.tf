# 1. Kinesis Video Stream to receive the camera feed
resource "aws_kinesis_video_stream" "gate_stream" {
  name      = "${var.project_name}-gate-stream-${var.environment}"
  data_retention_in_hours = 24
  tags      = var.tags
}

# 2. SNS Topic for Rekognition to publish detection results
resource "aws_sns_topic" "plate_detections" {
  name = "${var.project_name}-plate-detections-${var.environment}"
  tags = var.tags
}

# 3. IAM Role for the Rekognition Stream Processor
resource "aws_iam_role" "rekognition_processor_role" {
  name = "${var.project_name}-rekognition-role-${var.environment}"

  # This policy allows the Rekognition service to assume this role.
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "rekognition.amazonaws.com"
        }
      }
    ]
  })
  tags = var.tags
}

# 4. IAM Policy granting the necessary permissions to the role
resource "aws_iam_policy" "rekognition_processor_policy" {
  name        = "${var.project_name}-rekognition-policy-${var.environment}"
  description = "Policy for the Rekognition Stream Processor to access Kinesis and SNS."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "kinesisvideo:GetDataEndpoint",
          "kinesisvideo:GetMedia"
        ],
        Resource = aws_kinesis_video_stream.gate_stream.arn
      },
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = aws_sns_topic.plate_detections.arn
      }
    ]
  })
}

# 5. Attach the policy to the role
resource "aws_iam_role_policy_attachment" "rekognition_attach" {
  role       = aws_iam_role.rekognition_processor_role.name
  policy_arn = aws_iam_policy.rekognition_processor_policy.arn
}

# 6. The Rekognition Stream Processor itself
resource "aws_rekognition_stream_processor" "license_plate_detector" {
  name     = "${var.project_name}-plate-detector-${var.environment}"
  role_arn = aws_iam_role.rekognition_processor_role.arn

  # Input stream configuration
  input {
    kinesis_video_stream {
      arn = aws_kinesis_video_stream.gate_stream.arn
    }
  }

  # Output configuration
  output {
    sns_topic {
      arn = aws_sns_topic.plate_detections.arn
    }
  }

  # Settings for text detection (license plates)
  # Note: Filtering for specific formats (6-8 digits) or colors happens
  # in the Lambda function that processes these results, not here.
  settings {
    text_detection {
      confidence_threshold = 80 # Only report text with at least 80% confidence
    }
  }

  tags = var.tags
}