# This resource is used to create a container repository for our docker image to reside in and whereever there is a change in docker image this is where 
# the new image goes and also the ec2 instance will consult this repository for latest images and will update accordingly without using ansible this is 
# where every configuration comes from (i.e docker images)

resource "aws_ecr_repository" "app-repo" {
  name = "zero-downtime-deployment"

  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
}