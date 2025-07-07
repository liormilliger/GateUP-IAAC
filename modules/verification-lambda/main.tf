data "archive_file" "lambda_placeholder" {
  type        = "zip"
  output_path = "${path.module}/placeholder.zip"

  source {
    content  = "lambda placeholder"
    filename = "placeholder.txt"
  }
}

# 1. IAM Role for the Verification Lambda
resource "aws_iam_role" "verification_lambda_role" {
  name = "${var.project_name}-verification-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.tags
}

# 2. IAM Policy with all necessary permissions
resource "aws_iam_policy" "verification_lambda_policy" {
  name        = "${var.project_name}-verification-lambda-policy-${var.environment}"
  description = "Policy for the Verification Lambda."

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      # Basic execution permissions for logging
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      },
      # Kinesis Video Stream permissions to get images
      {
        Effect   = "Allow",
        Action   = [
          "kinesisvideo:GetDataEndpoint",
          "kinesisvideo:GetMediaForFragmentList",
          "kinesisvideo:ListFragments"
        ],
        Resource = var.kinesis_video_stream_arn
      },
      # Rekognition permissions to detect text
      {
        Effect   = "Allow",
        Action   = "rekognition:DetectText",
        Resource = "*" # DetectText API does not support resource-level permissions
      },
      # DynamoDB permissions to check license plates and write logs
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:PutItem"
        ],
        Resource = var.dynamodb_table_arns
      },
      # SNS publish permissions to send notifications
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = var.sns_topic_arn
      }
    ]
  })
}

# 3. Attach policy to the role
resource "aws_iam_role_policy_attachment" "verification_lambda_attach" {
  role       = aws_iam_role.verification_lambda_role.name
  policy_arn = aws_iam_policy.verification_lambda_policy.arn
}

# 4. The Lambda Function itself
resource "aws_lambda_function" "verification_lambda" {
  function_name = "${var.project_name}-verification-lambda-${var.environment}"
  role          = aws_iam_role.verification_lambda_role.arn
  handler       = "main.handler"
  runtime       = "python3.9"
  timeout       = 60

  # --- START OF CHANGE ---
  # Use the dynamically generated zip file from the archive_file data source.
  filename         = data.archive_file.lambda_placeholder.output_path
  source_code_hash = data.archive_file.lambda_placeholder.output_base64sha256
  # --- END OF CHANGE ---

  tags = var.tags
}

# 5. CloudWatch Event Rule to trigger the Lambda every 1 minute
resource "aws_cloudwatch_event_rule" "lambda_trigger" {
  name                = "${var.project_name}-lambda-trigger-${var.environment}"
  description         = "Triggers the verification lambda periodically"
  schedule_expression = "rate(1 minute)"
}

# 6. CloudWatch Event Target to link the rule to the Lambda
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_trigger.name
  target_id = "TriggerVerificationLambda"
  arn       = aws_lambda_function.verification_lambda.arn
}

# 7. Lambda Permission to allow CloudWatch Events to invoke the function
resource "aws_lambda_permission" "cloudwatch_invoke" {
  statement_id  = "AllowCloudWatchToInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.verification_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_trigger.arn
}
