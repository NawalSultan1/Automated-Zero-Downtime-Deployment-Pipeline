# This resource is used to create a container repository for our docker image to reside in and whereever there is a change in docker image this is where 
# the new image goes and also the ec2 instance will consult this repository for latest images and will update accordingly without using ansible this is 
# where every configuration comes from (i.e docker images)

# This file's ONLY job is to define the blueprint for our ECR repository.
# It tells Terraform to CREATE this resource.

resource "aws_ecr_repository" "prod-ecr" {
  # This is the local name Terraform uses. The rest of our code
  # will refer to the repository as "aws_ecr_repository.app".


  # This is the actual name of the repository that will be created in AWS.
  name = "prod-ecr"

  # This is a security setting to prevent accidentally overwriting image tags.
  image_tag_mutability = "IMMUTABLE"

  # This enables encryption for our images stored in the repository.
  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Project = var.project_name
  }
}
