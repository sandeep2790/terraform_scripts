i# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

# Create a VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "myigw"
  }
}

resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "mysubnet"
  }
}

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

  route = []

  tags = {
    Name = "myrt"
  }
}

resource "aws_route" "r" {
  route_table_id         = aws_route_table.myrt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myigw.id
  depends_on             = [aws_route_table.myrt]
}

resource "aws_security_group" "mysg" {
  name        = "allow_all_traffic"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "All Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "all-traffic"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_instance" "myserver1" {
  ami           = "ami-05bfbece1ed5beb54"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mysubnet.id

  tags = {
    Name = "myserver1"
  }
}

resource "aws_instance" "myserver2" {
  ami           = "ami-09c08b542a3df6eac"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mysubnet.id

  tags = {
    Name = "myserver2"
  }
}
