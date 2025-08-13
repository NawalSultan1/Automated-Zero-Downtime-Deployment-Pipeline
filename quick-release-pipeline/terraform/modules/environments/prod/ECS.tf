# -----------------------------------------------------------------------------
# DEFINITION 1: THE ECS CLUSTER (The "Restaurant Company")
# -----------------------------------------------------------------------------
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# -----------------------------------------------------------------------------
# DEFINITION 2: THE TASK DEFINITION (The Official "Recipe Card")
# -----------------------------------------------------------------------------
resource "aws_ecs_task_definition" "app" {
  family                   = "zero-downtime-app-task"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile("${path.module}/task-definitions/app.json.tpl", {
    app_image = aws_ecr_repository.app.repository_url
  })
}

# -----------------------------------------------------------------------------
# DEFINITION 3 & 4: THE ECS SERVICES (The "Blue & Green Kitchen Managers")
# -----------------------------------------------------------------------------

# The Blue Kitchen Manager
resource "aws_ecs_service" "blue" {
  name            = "blue-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.blue-tg.arn
    container_name   = "zero-downtime-app-container"
    container_port   = 80
  }

  # THIS IS THE FIX. The dependency was missing from the list.
  # This ensures the IAM role for the task exists before the service tries to start.
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
}


# The Green Kitchen Manager
resource "aws_ecs_service" "green" {
  name            = "green-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.green-tg.arn
    container_name   = "zero-downtime-app-container"
    container_port   = 80
  }

}