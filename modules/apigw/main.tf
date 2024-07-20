
#========================================================================
# API Gateway section
#========================================================================

resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "${var.apigw_name}-${random_string.random.id}"
  description = "REST API for ${var.apigw_name}"
}

resource "aws_api_gateway_resource" "newsitem" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "newsitem"
}

resource "aws_api_gateway_resource" "news" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "news"
}

resource "aws_api_gateway_method" "post_newsitem" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.newsitem.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "get_news" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.news.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "post_newsitem" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.newsitem.id
  http_method             = aws_api_gateway_method.post_newsitem.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.apigw_lambda_ddb.invoke_arn
}

resource "aws_api_gateway_integration" "get_news" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.news.id
  http_method             = aws_api_gateway_method.get_news.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.apigw_lambda_ddb.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.post_newsitem,
    aws_api_gateway_integration.get_news
  ]

  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = "default"
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${var.apigw_name}-${random_string.random.id}"
  retention_in_days = var.apigw_log_retention
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.apigw_lambda_ddb.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}
resource "random_string" "random" {
  length           = 4
  special          = false
}

//Define lambda function
resource "aws_lambda_function" "apigw_lambda_ddb" {
  function_name = "${var.lambda_name}-${random_string.random.id}"
  description = "serverless db query"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lampda-bucket.key

  runtime = "python3.8"
  handler = "app.lambda_handler"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
  
  environment {
    variables = {
      DDB_TABLE = var.dynamodb_table
    }
  }
  depends_on = [aws_cloudwatch_log_group.lambda_logs]
  
}
