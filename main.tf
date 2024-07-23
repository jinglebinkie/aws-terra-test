provider "aws" {
  region  = "eu-central-1"
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


module "dynamodb" {
  source = "./modules/dynamodb"
}

module "apigw" {
  source = "./modules/apigw"
}