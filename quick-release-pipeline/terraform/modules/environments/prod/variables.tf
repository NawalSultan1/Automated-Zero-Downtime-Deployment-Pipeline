variable "aws_region" {
     type = string
     description = "The region blue and green server run on"
}
variable "instance_type" {
  type = string
  description = "The type of instance to run"
}
variable "key_name_blue" {
  description = "The name of the key to be used to ssh into the server"
  type = string
}
variable "public_key_blue" {
  description = "public key of the server"
  type = string
}
data "aws_vpc" "default" {
   default = true
}
data "aws_subnets" "default" {
    filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
