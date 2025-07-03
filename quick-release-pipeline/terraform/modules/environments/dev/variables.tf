variable "aws_region" {
  type = string
  description = "To define the region in which the resourses will form"
  default = "us-southeast-2"
}

variable "instance_type" {
  description = "The size of the instances to be created"
  type = string
  default = "t2.micro"
}