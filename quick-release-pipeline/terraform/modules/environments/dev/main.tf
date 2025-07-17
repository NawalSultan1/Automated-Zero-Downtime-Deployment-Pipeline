provider "aws" {
  region = var.aws_region
}
resource "aws_key_pair" "blue_key" {             //here we are telling aws to create a box with the name key_name and in that key_name add this public key given below
  key_name = var.key_name                    //this public key and the key name are given from variables (which act as an empty form) and tfvars file(which act as the answers to the empty form i.e variables.tf)
  public_key = file(var.public_key)
}
resource "aws_instance" "Blue_Server" {
  ami = "ami-020cba7c55df1f615"
  instance_type = var.instance_type
  key_name = aws_key_pair.blue_key.key_name
  vpc_security_group_ids = [aws_security_group.blue-sg.id]
  tags = {
    Name= "Blue_server"
    Project = "quick_release_pipeline"
    Environment = "dev"
  }
  lifecycle {
    create_before_destroy = true
  }
}
//The security group (firewall) defining the rules for in and outbound traffic
resource "aws_security_group" "blue-sg" {
  name = "BlueGroup"
  description = "To Allow traffic flow from the server"
  vpc_id = data.aws_vpc.default.id           //inside which vpc this security group should be 

  ingress  {
    description = "SSH for admins"
    from_port = 22  //default port for ssh
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  //all traffic from all ip addresses
  }
  ingress {
    description = "https for application traffic"
    from_port = 80 // default port for http but for https use port 443 which is encrypted 
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  //all traffic from all ip addresses
  }
  egress {
    description = "Allow all outbound traffic"
    from_port = 0    //allow from every port 
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]  //all traffic from all ip addresses
  }
  tags = {
    Name = "blue-sg" //giving the server a new meaningful name 
  }
}