//Creating ASG's for blue and green servers
//using launch templates to create the ASG's for blue and green servers
// ASG's are responsible for scaling the instances up and down based on the load and if one is down create a new one to replace it.

resource "aws_launch_template" "blue-lt" {
  name = "blue-lt"
  image_id = data.aws_ssm_parameter.ecs-optimized-ami.value
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.prod-sg-instance.id]  
  iam_instance_profile {
     name = aws_iam_instance_profile.prod-webserver-profile.name
  }
 user_data = base64encode(<<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.main-cluster.name} >> /etc/ecs/ecs.config
              EOF
  )
   tags = {
    Name = "blue-launch-template"
  }
}

resource "aws_launch_template" "green-lt" {
  name = "green-lt"

  image_id = data.aws_ssm_parameter.ecs-optimized-ami.value

  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.prod-sg-instance.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.prod-webserver-profile.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.main-cluster.name} >> /etc/ecs/ecs.config
              EOF
  )

  tags = {
    Name = "green-launch-template"
  }
}

resource "aws_autoscaling_group" "blue-asg" {
  name = "blue-asg"
  desired_capacity = 1
  max_size = 1
  min_size = 1
  vpc_zone_identifier = [aws_subnet.private-prod-subnet-1.id]

  launch_template {
    id = aws_launch_template.blue-lt.id
     version = "$Latest" 
  }
  tag {
    key                = "Name"
    value               = "blue-server"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_group" "green-asg" {
  name = "green-asg"
  desired_capacity = 1
  max_size = 1
  min_size = 1
  vpc_zone_identifier = [aws_subnet.private-prod-subnet-2.id]

  launch_template {
    id = aws_launch_template.green-lt.id
     version = "$Latest" 
  }
  tag {
    key                = "Name"
    value               = "green-server"
    propagate_at_launch = true
  }
  
}
# Security group for both blue and green server (prod server)

resource "aws_security_group" "prod-sg-lb" {
  vpc_id = aws_vpc.prod-vpc.id
  description = "Defining the traffic rules the Load Balancer"
  name = "prod-sg-lb"
  ingress {
     description = "allow user traffic with https"
     from_port = 80
     to_port = 80
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
     description = "allow all outgoing traffic"
     from_port = 0
     to_port = 0
     protocol = -1
     cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "prod-sg"
    Environment = "prod"
  }
}
resource "aws_security_group" "prod-sg-instance" {
  vpc_id = aws_vpc.prod-vpc.id
  description = "Defining the securtiy rules for instances"
  name = "prod-sg-instance"
  egress {

    from_port = 0
    to_port = 0
    protocol = -1 
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags ={
    Name = "prod-sg-instance"
  }
}
 resource "aws_security_group_rule" "instance_rules" {
  type = "ingress"
  security_group_id = aws_security_group.prod-sg-instance.id
  description = "Allow HTTP traffic from load balancer"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = aws_security_group.prod-sg-lb.id
}  