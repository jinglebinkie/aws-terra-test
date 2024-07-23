provider "aws" {
  region  = "eu-central-1"
  #profile = "jingle"
  #shared_credentials_files  = ["/root/.aws/credentials"]
  #shared_config_files      = ["/root/.aws/config"]
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

# module "lambda" {
#   source = "./modules/lambda"
# }

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "apigw" {
  source = "./modules/apigw"
}