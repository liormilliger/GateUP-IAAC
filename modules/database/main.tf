# 1. Residents Table
resource "aws_dynamodb_table" "residents" {
  name         = "${var.project_name}-residents-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "license_plate"

  attribute {
    name = "license_plate"
    type = "S"
  }

  tags = var.tags
}

# 2. Guests Table
resource "aws_dynamodb_table" "guests" {
  name         = "${var.project_name}-guests-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "license_plate"

  attribute {
    name = "license_plate"
    type = "S"
  }

  # Enable Time To Live (TTL) for automatic cleanup of guest records.
  ttl {
    attribute_name = "expiration_ttl"
    enabled        = true
  }

  tags = var.tags
}

# 3. Logs Table
resource "aws_dynamodb_table" "logs" {
  name         = "${var.project_name}-logs-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_date"
  range_key    = "event_timestamp"

  attribute {
    name = "event_date"
    type = "S"
  }

  attribute {
    name = "event_timestamp"
    type = "S"
  }

  tags = var.tags
}

# 4. Trespassing Table
resource "aws_dynamodb_table" "trespassing" {
  name         = "${var.project_name}-trespassing-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "event_date"
  range_key    = "event_timestamp"

  attribute {
    name = "event_date"
    type = "S"
  }

  attribute {
    name = "event_timestamp"
    type = "S"
  }

  tags = var.tags
}