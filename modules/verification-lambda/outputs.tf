output "lambda_function_name" {
  description = "The name of the verification Lambda function."
  value       = aws_lambda_function.verification_lambda.function_name
}
