# The Restaurant Company
resource "aws_ecs_cluster" "main-cluster" {
  name = "main-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# The Official Recipe Card
resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "ecs-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  # ------ THIS IS THE PRIMARY FIX ------
  # The path now correctly starts from the current module's directory.
  # It tells Terraform: "In the same folder where this ecs.tf file lives,
  # find the 'task-definitions' subfolder and open 'app.json.tpl'."
  container_definitions = templatefile("${path.module}/task-definitions/app.json.tpl", {
    app_image = aws_ecr_repository.app.repository_url
  })
}

# The Blue Kitchen Manager
resource "aws_ecs_service" "blue" {
  name            = "blue-service"
  cluster         = aws_ecs_cluster.main-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets = [
      aws_subnet.private-prod-subnet-1.id,
      aws_subnet.private-prod-subnet-2.id
    ]
    security_groups = [aws_security_group.prod-sg-instance.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue-tg.arn
    container_name   = "zero-downtime-app-container"
    container_port   = 80
  }

  # ------ THIS IS THE SECONDARY FIX ------
  # This dependency is more robust. It ensures the service isn't created
  # until the load balancer listener it depends on is fully ready.
  depends_on = [aws_lb_listener.prod-lb-listener]
}

# The Green Kitchen Manager
resource "aws_ecs_service" "green" {
  name            = "green-service"
  cluster         = aws_ecs_cluster.main-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets = [
      aws_subnet.private-prod-subnet-1.id,
      aws_subnet.private-prod-subnet-2.id
    ]
    security_groups = [aws_security_group.prod-sg-instance.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.green-tg.arn
    container_name   = "zero-downtime-app-container"
    container_port   = 80
  }
  
  # This dependency is also updated for robustness.
  depends_on = [aws_lb_listener.prod-lb-listener]
}