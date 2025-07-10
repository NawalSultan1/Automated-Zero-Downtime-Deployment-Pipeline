provider "aws" {
  region = var.aws_region
}
resource "aws_key_pair" "blue" {             //here we are telling aws to create a box with the name key_name and in that key_name add this public key given below
  key_name = var.key_name                    //this public key and the key name are given from variables (which act as an empty form) and tfvars file(which act as the answers to the empty form i.e variables.tf)
  public_key = var.public_key
}

resource "aws_instance" "first_Server" {
  ami = "ami-020cba7c55df1f615"
  instance_type = var.instance_type
  tags = {
    Name= "First_server"
    Project = "quick_release_pipeline"
    Environment = "dev"
  }
}
