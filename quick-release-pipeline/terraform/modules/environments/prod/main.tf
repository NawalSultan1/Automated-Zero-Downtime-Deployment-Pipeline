provider "aws" {
  region = var.aws_region
}

#Blue Server IaC

resource "aws_key_pair" "blue-key" {
     key_name = var.key_name_blue
     public_key = file(var.public_key_blue)
}
resource "aws_instance" "blue-server" {
  instance_type = var.instance_type
  ami = "ami-020cba7c55df1f615"
  key_name = aws_key_pair.blue-key.key_name
  vpc_security_group_ids = [aws_security_group.prod-sg.id]
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
  key_name = aws_key_pair.blue-key.key_name
  vpc_security_group_ids = [aws_security_group.prod-sg.id]
  tags = {
    Name = "green-server"
    Environment = "Production"
    Project= "Zero-downtime-deployment-pipeline"
  }
}

# Security group for both blue and green server (prod server)

resource "aws_security_group" "prod-sg" {
  vpc_id = data.aws_vpc.default.id
  description = "Defining the traffic rules for Blue Server"
  name = "prod-sg"

  ingress {
     description ="allow admin to SSH into server"
     from_port = 22
     to_port = 22
     protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }
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

