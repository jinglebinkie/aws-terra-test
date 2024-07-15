provider "aws" {
  region  = "eu-central-1"
  profile = "jingle"
  shared_credentials_files  = ["/root/.aws/credentials"]
  shared_config_files      = ["/root/.aws/config"]
}

terraform {
  backend "s3" {
    bucket                  = "tf-bucket-mr"
    key                     = "terraform-test"
    region                  = "eu-central-1" 
  }
}
resource "random_string" "random" {
  length           = 4
  special          = false
}


# resource "aws_instance" "example_server" {
#   ami           = "ami-0910ce22fbfa68e1d"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "test1"
#   }
# }

resource "aws_dynamodb_table" "tf-news-item-table" {
 name = "tf-news-item-table"
 billing_mode = "PROVISIONED"
 read_capacity= "30"
 write_capacity= "30"
 hash_key       = "news-item-id"
 range_key      = "date-news-item"
 attribute {
  name = "news-item-id"
  type = "N"
 }
  attribute {
  name = "date-news-item"
  type = "S"
 }
   attribute {
   name = "desc-news-item"
   type = "S"
  }
   global_secondary_index {
    name               = "DateIndex"
    hash_key           = "date-news-item"
    range_key          = "desc-news-item"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["news-item-id"]
  }
}
#create a bucket
resource "aws_s3_bucket" "lambda_bucket" {
  bucket_prefix = var.s3_bucket_prefix
  force_destroy = true
}
# set permission options so acl can be set private
# resource "aws_s3_bucket_ownership_controls" "lambda_bucket_privs" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }
# # set acl to private access 
# resource "aws_s3_bucket_acl" "private_bucket" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   acl    = "private"
# }

data "archive_file" "lambda_zip" {
  type = "zip"

  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src.zip"
}

resource "aws_s3_object" "lampda-bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "src.zip"
  source = data.archive_file.lambda_zip.output_path

  etag = filemd5(data.archive_file.lambda_zip.output_path)
}


//Define lambda function
resource "aws_lambda_function" "apigw_lambda_ddb" {
  function_name = "${var.lambda_name}-${random_string.random.id}"
  description = "serverlessland pattern"

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

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/${var.lambda_name}-${random_string.random.id}"

  retention_in_days = var.lambda_log_retention
}

resource "aws_iam_role" "lambda_exec" {
  name = "LambdaDdbPost"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_exec_role" {
  name = "lambda-tf-pattern-ddb-post"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:Scan",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:*:*:table/${var.dynamodb_table}"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_exec_role.arn
}

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
