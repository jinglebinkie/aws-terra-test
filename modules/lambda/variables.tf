# Input variable definitions

variable "s3_bucket_prefix" {
  description = "S3 bucket prefix"
  type = string
  default = "apigw-lambda-ddb"
  
}

variable "lambda_name" {
  description = "name of the lambda function"
  type = string
  default = "lampda-news-post"
  
}

variable "lambda_log_retention" {
  description = "lambda log retention in days"
  type = number
  default = 7
}

variable "dynamodb_table" {
  description = "name of the ddb table"
  type = string
  default = "tf-news-item-table"
  
}