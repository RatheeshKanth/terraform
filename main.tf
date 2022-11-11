locals {
  ssh_user         = "ubuntu"
  key_name         = "ec2_key"
  private_key_path = "~/Downloads/ec2_key.pem"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "test-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "EC2PrivateSubnet" {
    availability_zone = "ap-southeast-2b"
    cidr_block = "10.0.2.0/24"
    vpc_id = "${aws_vpc.test-vpc.id}"
    map_public_ip_on_launch = false
    tags = {
    Name = "EC2PrivateSubnet"
  }
}

resource "aws_subnet" "EC2PublicSubnet" {
    availability_zone = "ap-southeast-2a"
    cidr_block = "10.0.1.0/24"
    vpc_id = "${aws_vpc.test-vpc.id}"
    map_public_ip_on_launch = false
    tags = {
    Name = "EC2PublicSubnet"
  }
}

resource "aws_internet_gateway" "EC2InternetGateway" {
    vpc_id = "${aws_vpc.test-vpc.id}"
    tags = {
    Name = "EC2InternetGateway"
  }
}

resource "aws_route_table" "EC2RouteTablePublic" {
    vpc_id = "${aws_vpc.test-vpc.id}"

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.EC2InternetGateway.id
  }
    tags = {
    Name = "EC2RouteTablePublic"
  }
}

resource "aws_route_table" "EC2RouteTablePrivate" {
    vpc_id = "${aws_vpc.test-vpc.id}"
    tags = {
    Name = "EC2RouteTablePrivate"
  }
}
 

resource "aws_route_table_association" "EC2RTPublicAssociation" {
  subnet_id      = aws_subnet.EC2PublicSubnet.id
  route_table_id = aws_route_table.EC2RouteTablePublic.id
}

#Create security group with firewall rules
resource "aws_security_group" "test-SG" {
  name        = var.security_group
  description = "security group for ec2"

#inbound
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # outbound
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags= {
    Name = var.security_group
  }
}

resource "aws_instance" "test-ec2" {
  ami = var.ami_id
  key_name = var.key_name
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.test-SG.id]
  tags= {
    Name = var.tag_name
  }

  provisioner "remote-exec" {
      inline = ["echo 'Wait until SSH is ready'"]

      connection {
        type        = "ssh"
        user        = local.ssh_user
        private_key = file(local.private_key_path)
        host        = aws_instance.test-ec2.public_ip
      }
    }
    provisioner "local-exec" {
      command = "ansible-playbook  -i ${aws_instance.test-ec2.public_ip}, --private-key ${local.private_key_path} nginx.yaml"
    }
}

# Create Elastic IP address
resource "aws_eip" "testElasticIP" {
  vpc      = true
  instance = aws_instance.test-ec2.id
tags= {
    Name = "test_elastic_ip"
  }
}
