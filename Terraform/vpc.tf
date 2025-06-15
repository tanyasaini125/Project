
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "my-tf-vpc"
  }
}

## THis is Public Subnet
resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}

## THis is Private Subnet
resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet"
  }
}

## This is IGW
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "aws igw"
  }
}

## THis is Route Table
resource "aws_route_table" "route" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "route"
  }
}

## This is Route Table Association
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.route.id
}

## This is Security Group
resource "aws_security_group" "Firewall" {
  name        = "My-Sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "Securtiy-Group"
  }
}

## Allow Inbound Rules
resource "aws_vpc_security_group_ingress_rule" "inbound-rules" {
  security_group_id = aws_security_group.Firewall.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

## Allow outbound Rules
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.Firewall.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # means all protocols
}
