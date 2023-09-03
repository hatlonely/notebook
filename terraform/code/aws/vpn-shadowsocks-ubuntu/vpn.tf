terraform {
  cloud {
    organization = "hatlonely"

    workspaces {
      name = "aws-shadowsocks-ubuntu"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.13.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

variable "name" {
  type    = string
  default = "ss"
}

variable "encryption_method" {
  type    = list(string)
  default = ["aes-256-gcm", "aes-256-ctr", "chacha20-ietf-poly1305"]
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

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association_subnet" {
  route_table_id = aws_route_table.route-table.id
  subnet_id      = aws_subnet.subnet.id
}

# 生成登录秘钥对
resource "tls_private_key" "tls_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 保存秘钥
resource "local_file" "file_id_rsa" {
  filename        = "id_rsa"
  content         = tls_private_key.tls_private_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "file_id_rsa_pub" {
  filename = "id_rsa.pub"
  content  = tls_private_key.tls_private_key.public_key_openssh
}

# 创建秘钥对
resource "aws_key_pair" "key_pair" {
  key_name   = "${var.name}-key-pair"
  public_key = tls_private_key.tls_private_key.public_key_openssh
}

# 创建安全组
resource "aws_security_group" "security_group" {
  name   = "${var.name}-security-group"
  vpc_id = aws_vpc.vpc.id
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "ssh"
    from_port        = random_integer.ss_port.result
    to_port          = random_integer.ss_port.result + length(var.encryption_method) - 1
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

# 创建 EC2 实例
resource "aws_instance" "instance" {
  ami                         = data.aws_ami.ubuntu_22.id
  instance_type               = "t3.nano"
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.security_group.id]
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true
  iam_instance_profile        = "AmazonSSMRoleForInstancesQuickSetup"
}

# 生成密码
resource "random_password" "ss_password" {
  length  = 16
  special = false
}

# 随机端口
resource "random_integer" "ss_port" {
  max = 60000
  min = 20000
}

# 创建启动脚本
resource "aws_ssm_document" "ssm_document_init_instance" {
  name            = "${var.name}-ssm-document-init-instance"
  document_type   = "Command"
  document_format = "YAML"
  content         = <<EOT
schemaVersion: '1.2'
description: test ssm
parameters: {}
runtimeConfig:
  'aws:runShellScript':
    properties:
      - id: '0.aws:runShellScript'
        runCommand:
          - |
            #!/usr/bin/env bash

            # 安装 shadowsocks-libev
            # https://github.com/shadowsocks/shadowsocks-libev
            sudo apt update -y
            sudo apt install -y shadowsocks-libev
            # 关闭默认服务
            sudo systemctl disable shadowsocks-libev
            sudo systemctl stop shadowsocks-libev

            sudo mkdir -p /etc/shadowsocks-libev
            ss_port=${random_integer.ss_port.result}
            for encryption_method in ${join(" ", var.encryption_method)}; do
              # 配置文件
              sudo bash -c "cat > /etc/shadowsocks-libev/config.$${encryption_method}.json <<EOF
            {
                \"server\": \"0.0.0.0\",
                \"server_port\": $${ss_port},
                \"password\": \"${random_password.ss_password.result}\",
                \"timeout\": 300,
                \"method\": \"$${encryption_method}\",
                \"fast_open\": false,
                \"workers\": 1,
                \"prefer_ipv6\": false
            }
            EOF
            "
              ((ss_port++))

              # 配置服务
              sudo bash -c "cat > /etc/systemd/system/shadowsocks-libev-$${encryption_method}.service <<EOF
            [Unit]
            Description=Shadowsocks-libev Server
            After=network.target

            [Service]
            Type=simple
            ExecStart=/usr/bin/ss-server -c /etc/shadowsocks-libev/config.$${encryption_method}.json -u
            Restart=on-abort

            [Install]
            WantedBy=multi-user.target
            EOF
            "

              # 启动服务
              sudo systemctl start shadowsocks-libev-$${encryption_method}
              sudo systemctl enable shadowsocks-libev-$${encryption_method}

            done

        workingDirectory: /root
        timeoutSeconds: 600
EOT
}

# 执行启动脚本
resource "aws_ssm_association" "ssm_association_init_instance" {
  name = aws_ssm_document.ssm_document_init_instance.name
  targets {
    key    = "InstanceIds"
    values = [aws_instance.instance.id]
  }
}

output "ssh_connection" {
  value = chomp(<<EOF
ssh -i id_rsa ubuntu@${aws_instance.instance.public_ip}
EOF
  )
}

output "ss_connection" {
  value = chomp(join("\n", [
    for idx, method in var.encryption_method : <<EOF
host: ${aws_instance.instance.public_ip}
port: ${random_integer.ss_port.result + idx}
password: ${nonsensitive(random_password.ss_password.result)}
method: ${method}
EOF
  ]))
}
