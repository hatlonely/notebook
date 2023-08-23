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
resource "aws_vpc" "tf-test-vpc" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "tf-test-subnet" {
  vpc_id            = aws_vpc.tf-test-vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "172.31.1.0/24"
}

# 生成登录秘钥对
resource "tls_private_key" "tf-test-key-pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 保存秘钥
resource "local_file" "tf-test-id-rsa" {
  filename = "id_rsa"
  content  = tls_private_key.tf-test-key-pair.private_key_pem
}

resource "local_file" "tf-test-id-rsa-pub" {
  filename = "id_rsa.pub"
  content  = tls_private_key.tf-test-key-pair.public_key_openssh
}

# 创建秘钥对
resource "aws_key_pair" "tf-test-key-pair" {
  key_name   = "tf-test-key-pair"
  public_key = tls_private_key.tf-test-key-pair.public_key_openssh
}

# 创建安全组
resource "aws_security_group" "tf-test-security-group" {
  name   = "tf-test-security-group"
  vpc_id = aws_vpc.tf-test-vpc.id
  ingress {
    description      = "ssh"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
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

resource "aws_instance" "tf-test-instance" {
  ami                         = data.aws_ami.ubuntu_22.id
  instance_type               = "t3.nano"
  key_name                    = aws_key_pair.tf-test-key-pair.key_name
  security_groups             = [aws_security_group.tf-test-security-group.id]
  subnet_id                   = aws_subnet.tf-test-subnet.id
  associate_public_ip_address = true
}

output "connection" {
  value = "ssh -i id_rsa ubuntu@${aws_instance.tf-test-instance.public_ip}"
}
