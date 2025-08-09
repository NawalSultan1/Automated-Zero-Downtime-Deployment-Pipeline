resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
  setting {                   // To unable certain cluster level features or disable them
     name  = "containerInsights"    // This enables container insights for the ECS cluster giving insights into the performance and health of the containers
     value = "enabled"      // This enables the container insights feature
  }
  tags = {
    Environment = "prod"
    Project     = var.project_name
  }
}