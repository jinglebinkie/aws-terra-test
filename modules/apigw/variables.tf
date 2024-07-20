variable "apigw_name" {
  description = "name of the lambda function"
  type = string
  default = "apigw-http-news"
  
}

variable "apigw_log_retention" {
  description = "api gwy log retention in days"
  type = number
  default = 7
}