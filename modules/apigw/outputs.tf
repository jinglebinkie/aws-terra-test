
# Output value definitions

output "apigwy_url" {
  description = "URL for API Gateway stage"

  #value = aws_apigatewayv2_stage.default.invoke_url
  value = aws_api_gateway_deployment.api_deployment
}


output "apigwy_log_group" {
  description = "Name of the CloudWatch logs group for the lambda function"

  value = aws_cloudwatch_log_group.api_gw.id
}
