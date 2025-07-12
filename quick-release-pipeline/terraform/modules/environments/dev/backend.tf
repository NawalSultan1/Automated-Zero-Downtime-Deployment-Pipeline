terraform{
     backend "s3" {
          bucket = "nawalsultan123"
          key = "terraform.tfstate"
          region = "us-east-1"
     }
     
}
