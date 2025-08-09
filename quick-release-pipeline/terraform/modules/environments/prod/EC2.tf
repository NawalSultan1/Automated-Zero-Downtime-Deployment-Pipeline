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
              echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
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
              echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
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


#  resource "aws_security_group_rule" "instance_rules" {   //make this more secure with bastion hosts@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#   type = "ingress"
#   security_group_id = aws_security_group.prod-sg-instance.id
#   description = "allow ssh for admins"
#   from_port = 22
#   to_port = 22
#   protocol = "tcp"
#   source_security_group_id = aws_security_group.prod-sg-lb.id
# }  

//this is used to allow ssh access to the instances from the load balancer security group (traffic coming from the load balancer to ssh into the instances but
// it leaves the port 22 open which is a security concerns
// so we have to remove it and go to the IAM role method which doesnot leave any port open rather it uses the amazon ssm service to ssh into the instances
// the admin will go to the ssm serveice and ask it to connect to the instance)

# #Blue Server IaC

# # resource "aws_key_pair" "blue-key" {
# #      key_name = var.key_name_blue
# #      public_key = file(var.public_key_blue)
# # } //no need to use this resource when using an iam 
# resource "aws_instance" "blue-server" {
#   instance_type = var.instance_type
#   ami = data.aws_ssm_parameter.ecs-optimized-ami.value
#   # key_name = aws_key_pair.blue-key.key_name  // use when you want a resource to have access to everything
#   iam_instance_profile = aws_iam_instance_profile.prod-webserver-profile.name
#   vpc_security_group_ids = [aws_security_group.prod-sg-instance.id]
#   subnet_id = aws_subnet.private-prod-subnet-1.id
#   tags = {
#     Name = "blue-server"
#     description = "Production Server Blue Server"
#     Environment = "Production"
#     Project = "Zero-downtime-deployment-pipeline"
#   }
# }

# # Green Server IaC

# resource "aws_instance" "green-server" {
#   instance_type = var.instance_type
#   ami = data.aws_ssm_parameter.ecs-optimized-ami.value
#   # key_name = aws_key_pair.blue-key.key_name // use when you want a resource to have access to everything
#   iam_instance_profile = aws_iam_instance_profile.prod-webserver-profile.name
#   vpc_security_group_ids = [aws_security_group.prod-sg-instance.id]
#   subnet_id = aws_subnet.private-prod-subnet-2.id
#   tags = {
#     Name = "green-server"
#     Environment = "Production"
#     Project= "Zero-downtime-deployment-pipeline"
#   }
# }