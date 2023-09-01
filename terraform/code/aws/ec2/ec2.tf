terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.13.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


data "aws_ami" "ubuntu_22" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230516"]
  }
}

# 创建 vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.0.1.0/24"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association_subnet" {
  route_table_id = aws_route_table.route_table.id
  subnet_id      = aws_subnet.subnet.id
}

# 生成登录秘钥对
resource "tls_private_key" "tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 保存秘钥
resource "local_file" "file_id_rsa" {
  filename = "id_rsa"
  content  = tls_private_key.tls_private_key.private_key_pem
}

resource "local_file" "file_id_rsa_pub" {
  filename = "id_rsa.pub"
  content  = tls_private_key.tls_private_key.public_key_openssh
}

# 创建秘钥对
resource "aws_key_pair" "key_pair" {
  key_name   = "tf-test-key-pair"
  public_key = tls_private_key.tls_private_key.public_key_openssh
}

# 创建安全组
resource "aws_security_group" "security_group" {
  name   = "tf-test-security-group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "instance" {
  ami                         = data.aws_ami.ubuntu_22.id
  instance_type               = "t3.nano"
  key_name                    = aws_key_pair.key_pair.key_name
  security_groups             = [aws_security_group.security_group.id]
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true
}

output "connection" {
  value = "ssh -i id_rsa ubuntu@${aws_instance.instance.public_ip}"
}
