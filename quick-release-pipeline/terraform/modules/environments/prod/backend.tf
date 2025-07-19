terraform {
  backend "s3" {
    bucket = "nawalsultan123"
    key = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}