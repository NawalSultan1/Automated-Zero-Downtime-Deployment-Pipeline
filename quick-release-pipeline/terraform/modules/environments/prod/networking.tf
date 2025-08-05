resource "aws_vpc" "prod-vpc" {    //creating a custom vpc which allows 2 power 16 number of ip addresses
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true        
  enable_dns_support = true
  tags = {
    Name = "Main-VPC"
  }
}
# creating an internet gateway for inbound and outbound traffic
resource "aws_internet_gateway" "prod-gateway" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name="prod-igw"
  }
}

# Provisioning NAT gateway and it will reside in a public subnet

resource "aws_eip" "nat-eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "prod-natgw" {
  subnet_id = aws_subnet.prod-subnet-1.id
  allocation_id = aws_eip.nat-eip.id
  depends_on = [ aws_internet_gateway.prod-gateway ]
}

# creating 2 public 

resource "aws_subnet" "prod-subnet-1" {
  vpc_id = aws_vpc.prod-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}
resource "aws_subnet" "prod-subnet-2" {
  vpc_id = aws_vpc.prod-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"
}

#  creating 2 private subnets for instances 

resource "aws_subnet" "private-prod-subnet-1" {
  cidr_block = "10.0.102.0/24"
  availability_zone = "us-east-1a"
  vpc_id = aws_vpc.prod-vpc.id
}
resource "aws_subnet" "private-prod-subnet-2" {
  cidr_block = "10.0.101.0/24"
  vpc_id = aws_vpc.prod-vpc.id
  availability_zone = "us-east-1b"
}

# Creating route table // for private subnets 

resource "aws_route_table" "prod-rt" {
  vpc_id = aws_vpc.prod-vpc.id
  route  {
     cidr_block = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.prod-natgw.id
  }
}

#Creating route table association for each public subnet

resource "aws_route_table_association" "subnet1" {
  subnet_id = aws_subnet.private-prod-subnet-1.id
  route_table_id = aws_route_table.prod-rt.id
}
resource "aws_route_table_association" "subnet2" {
  subnet_id = aws_subnet.private-prod-subnet-2.id
  route_table_id = aws_route_table.prod-rt.id
}

// Public route tables and route tables associations

resource "aws_route_table" "public-association" {
  vpc_id = aws_vpc.prod-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-gateway.id
  }
}

resource "aws_route_table_association" "public-association-table" {
  subnet_id = aws_subnet.prod-subnet-1.id
  route_table_id = aws_route_table.public-association.id
}
resource "aws_route_table_association" "public-association-table-2" {
  subnet_id = aws_subnet.prod-subnet-2.id
  route_table_id = aws_route_table.public-association.id
}
