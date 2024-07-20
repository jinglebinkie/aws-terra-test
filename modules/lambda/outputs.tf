
# Output value definitions

output "lambda_log_group" {
  description = "Name of the CloudWatch logs group for the lambda function"

  value = aws_cloudwatch_log_group.lambda_logs.id
}
