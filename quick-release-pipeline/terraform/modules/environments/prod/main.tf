provider "aws" {
  region = var.aws_region
}

#Blue Server IaC

# resource "aws_key_pair" "blue-key" {
#      key_name = var.key_name_blue
#      public_key = file(var.public_key_blue)
# } //no need to use this resource when using an iam 
resource "aws_instance" "blue-server" {
  instance_type = var.instance_type
  ami = "ami-020cba7c55df1f615"
  # key_name = aws_key_pair.blue-key.key_name  // use when you want a resource to have access to everything
  iam_instance_profile = aws_iam_instance_profile.prod-webserver-profile.name
  vpc_security_group_ids = [aws_security_group.prod-sg-instance.id]
  subnet_id = aws_subnet.private-prod-subnet-1.id
  tags = {
    Name = "blue-server"
    description = "Production Server Blue Server"
    Environment = "Production"
    Project = "Zero-downtime-deployment-pipeline"
  }
}

# Green Server IaC

resource "aws_instance" "green-server" {
  instance_type = var.instance_type
  ami = "ami-020cba7c55df1f615"
  # key_name = aws_key_pair.blue-key.key_name // use when you want a resource to have access to everything
  iam_instance_profile = aws_iam_instance_profile.prod-webserver-profile.name
  vpc_security_group_ids = [aws_security_group.prod-sg-instance.id]
  subnet_id = aws_subnet.private-prod-subnet-2.id
  tags = {
    Name = "green-server"
    Environment = "Production"
    Project= "Zero-downtime-deployment-pipeline"
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
  ingress {
  
    
  }
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
 resource "aws_security_group_rule" "instance_rules" {   //make this more secure with bastion hosts@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
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