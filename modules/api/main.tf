resource "aws_ecr_repository" "api" {
  name                 = "${var.project_name}-api-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

# 2. Lambda Function that runs the code from the ECR image
resource "aws_lambda_function" "api" {
  function_name = "${var.project_name}-api-${var.environment}"
  # The 'image_uri' will be updated by a CI/CD pipeline after a new image is pushed.
  # We use a placeholder for the initial creation.
  image_uri    = "${aws_ecr_repository.api.repository_url}:latest"
  package_type = "Image"
  role         = var.lambda_iam_role_arn
  timeout      = 30

  tags = var.tags
}

# 3. API Gateway (HTTP API) - simpler and cheaper than REST API
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-api-${var.environment}"
  protocol_type = "HTTP"
  tags          = var.tags
}

# 4. API Gateway Integration to connect the API to the Lambda function
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.api.invoke_arn
}

# 5. API Gateway Route - this catches all requests and sends them to the Lambda
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "$default" # A special key to catch all routes and methods
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# 6. API Gateway Stage - deploys the API to make it publicly accessible
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# 7. Lambda Permission - allows API Gateway to invoke our Lambda function
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
