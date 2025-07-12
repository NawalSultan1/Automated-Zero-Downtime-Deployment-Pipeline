variable "aws_region" {
  type = string
  description = "To define the region in which the resourses will form"
  default = "us-east-1"
}

variable "instance_type" {
  description = "The size of the instances to be created"
  type = string
  default = "t2.micro"
}
variable "key_name" {
  description = "The key to connect with the first server"
  type = string
}
variable "public_key" {
  description = "location of the public key"
  type = string
}
data "aws_vpc" "default" {
  default = true
}