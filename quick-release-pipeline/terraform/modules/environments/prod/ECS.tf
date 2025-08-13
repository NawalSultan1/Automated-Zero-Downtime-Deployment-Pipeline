
resource "aws_ecs_cluster" "main-cluster" {
  name = "main-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "ecs-task-definition"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile("/task-definitions/app.json.tpl", {
    app_image = aws_ecr_repository.prod-ecr.repository_url
  })
}

# The Blue cluster services
resource "aws_ecs_service" "blue" {
  name            = "blue-service"
  cluster         = aws_ecs_cluster.main-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.blue-tg.arn
    container_name   = "zero-downtime-app-container"
    container_port   = 80
  }

  # This ensures the IAM role for the task exists before the service tries to start.
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
}


# The ecs service for green server
resource "aws_ecs_service" "green" {
  name            = "green-service"
  cluster         = aws_ecs_cluster.main-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.green-tg.arn
    container_name   = "zero-downtime-app-container"
    container_port   = 80
  }

}