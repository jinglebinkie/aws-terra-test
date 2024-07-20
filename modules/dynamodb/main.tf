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