# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-central-1"
}

variable "s3_bucket_prefix" {
  description = "S3 bucket prefix"
  type = string
  default = "apigw-lambda-ddb"
  
}

variable "dynamodb_table" {
  description = "name of the ddb table"
  type = string
  default = "tf-news-item-table"
  
}

variable "lambda_name" {
  description = "name of the lambda function"
  type = string
  default = "lampda-news-post"
  
}

variable "apigw_name" {
  description = "name of the lambda function"
  type = string
  default = "apigw-http-news"
  
}

variable "lambda_log_retention" {
  description = "lambda log retention in days"
  type = number
  default = 7
}

variable "apigw_log_retention" {
  description = "api gwy log retention in days"
  type = number
  default = 7
}


