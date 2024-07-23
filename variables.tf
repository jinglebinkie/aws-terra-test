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
variable "apigw_name" {
  description = "name of the lambda function"
  type = string
  default = "apigw-http-news"
  
}
