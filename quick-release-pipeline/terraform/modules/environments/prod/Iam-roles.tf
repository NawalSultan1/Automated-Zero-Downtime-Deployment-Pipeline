resource "aws_iam_role" "prod-webserver-role" {   //Badge
  name = "prod-webserver-role"

  assume_role_policy = jsonencode({           //who can wear the badge
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "prod-webserver-role"
  }
}

# Attaches the first "permission slip" to the role.
# This specific policy allows AWS Systems Manager (SSM) to connect to the instance
# for terminal access, replacing the need for SSH keys and open port 22.
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {     //what permssions does a particular badge have 
  role       = aws_iam_role.prod-webserver-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attaches the second "permission slip" to the role.
# This policy allows the ECS Agent (software running on the instance) to
# communicate with the ECS control plane. It lets the instance register
# itself into the cluster and report its status.
resource "aws_iam_role_policy_attachment" "ecs_agent_policy_attachment" {
  role       = aws_iam_role.prod-webserver-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


# This creates the "badge holder" that allows the role to be physically
# attached to an EC2 instance at launch time.
resource "aws_iam_instance_profile" "prod-webserver-profile" {   //an instance can not wear the badge so we create a badge holder for it. 
  name = "prod-webserver-profile"
  role = aws_iam_role.prod-webserver-role.name
}


# -----------------------------------------------------------------------------
# ROLE 2: PERMISSIONS FOR THE ECS TASK (The "Software" or "Application" Role)
# Purpose: This role is NOT attached to the EC2 instance. It is assumed by the
# ECS service itself at runtime when it's about to start your container.
# Its ONLY job is to give your APPLICATION permission to do things.
# -----------------------------------------------------------------------------

# Defines the role and specifies that it can ONLY be assumed by the ECS Task service.
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attaches the required "permission slip" to this role.
# This specific AWS-managed policy grants permission to do two things:
#   1. Pull images from a private Amazon ECR repository.
#   2. Send container logs to Amazon CloudWatch Logs.
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}