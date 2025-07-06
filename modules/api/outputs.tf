output "ecr_repository_url" {
  description = "The URL of the ECR repository."
  value       = aws_ecr_repository.api.repository_url
}

output "api_gateway_endpoint" {
  description = "The invocation URL for the API Gateway."
  value       = aws_apigatewayv2_stage.default.invoke_url
}
