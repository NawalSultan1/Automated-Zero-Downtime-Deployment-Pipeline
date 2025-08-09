# This resource is used to create a container repository for our docker image to reside in and whereever there is a change in docker image this is where 
# the new image goes and also the ec2 instance will consult this repository for latest images and will update accordingly without using ansible this is 
# where every configuration comes from (i.e docker images)

resource "aws_ecr_repository" "app-repo" {
  name                 = "zero-downtime-deployment"
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  tags = {
    Environment = "prod"
    Project     = "zero-downtime-deployment"
  }
}

# Lifecycle policy to automatically expire untagged images older than 30 days
resource "aws_ecr_lifecycle_policy" "app_repo_policy" {
  repository = aws_ecr_repository.app-repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than 30 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repository_url" {  //gives the url of the ecr repository 
  value = aws_ecr_repository.app-repo.repository_url
  description = "The URL of the ECR repository"
  
}