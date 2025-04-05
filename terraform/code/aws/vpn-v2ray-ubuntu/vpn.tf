terraform {
  cloud {
    organization = "hatlonely"

    workspaces {
      name = "aws-v2ray-ubuntu"
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
  default = "v2ray"
}

variable "protocols" {
  type    = list(string)
  default = ["vmess", "vless"]
}

provider "aws" {
  region = "ap-southeast-1"
}

data "aws_ami" "ubuntu_22" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 创建 vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-southeast-1a"
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
    description      = "v2ray"
    from_port        = random_integer.v2ray_port.result
    to_port          = random_integer.v2ray_port.result + length(var.protocols) - 1
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
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.security_group.id]
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true
  iam_instance_profile        = "AmazonSSMRoleForInstancesQuickSetup"
}

# 生成用户ID
resource "random_uuid" "v2ray_uuid" {
}

# 随机端口
resource "random_integer" "v2ray_port" {
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
description: Install and configure V2Ray
parameters: {}
runtimeConfig:
  'aws:runShellScript':
    properties:
      - id: '0.aws:runShellScript'
        runCommand:
          - |
            #!/usr/bin/env bash

            # 网络优化
            sudo bash -c "cat > /etc/sysctl.d/local.conf <<EOF
            # max open files
            fs.file-max = 51200
            # max read buffer
            net.core.rmem_max = 67108864
            # max write buffer
            net.core.wmem_max = 67108864
            # default read buffer
            net.core.rmem_default = 65536
            # default write buffer
            net.core.wmem_default = 65536
            # max processor input queue
            net.core.netdev_max_backlog = 4096
            # max backlog
            net.core.somaxconn = 4096

            # resist SYN flood attacks
            net.ipv4.tcp_syncookies = 1
            # reuse timewait sockets when safe
            net.ipv4.tcp_tw_reuse = 1
            # turn off fast timewait sockets recycling
            net.ipv4.tcp_tw_recycle = 0
            # short FIN timeout
            net.ipv4.tcp_fin_timeout = 30
            # short keepalive time
            net.ipv4.tcp_keepalive_time = 1200
            # outbound port range
            net.ipv4.ip_local_port_range = 10000 65000
            # max SYN backlog
            net.ipv4.tcp_max_syn_backlog = 4096
            # max timewait sockets held by system simultaneously
            net.ipv4.tcp_max_tw_buckets = 5000
            # turn on TCP Fast Open on both client and server side
            net.ipv4.tcp_fastopen = 3
            # TCP receive buffer
            net.ipv4.tcp_rmem = 4096 87380 67108864
            # TCP write buffer
            net.ipv4.tcp_wmem = 4096 65536 67108864
            # turn on path MTU discovery
            net.ipv4.tcp_mtu_probing = 1

            # for high-latency network
            net.ipv4.tcp_congestion_control = hybla

            # for low-latency network, use cubic instead
            # net.ipv4.tcp_congestion_control = cubic
            EOF
            "
            sudo sysctl --system

            # 安装 v2ray
            # 使用官方安装脚本
            sudo apt update -y
            sudo apt install -y curl unzip

            # 下载并执行v2ray官方安装脚本
            curl -L https://github.com/v2fly/fhs-install-v2ray/raw/master/install-release.sh > install-release.sh
            sudo bash install-release.sh
            
            # 停止默认服务用于配置
            sudo systemctl stop v2ray

            # 配置v2ray
            v2ray_port=${random_integer.v2ray_port.result}
            
            for protocol in ${join(" ", var.protocols)}; do
              if [ "$protocol" = "vmess" ]; then
                # 创建VMess配置
                sudo bash -c "cat > /usr/local/etc/v2ray/config.$${protocol}.json <<EOF
                {
                  \"inbounds\": [{
                    \"port\": $${v2ray_port},
                    \"protocol\": \"vmess\",
                    \"settings\": {
                      \"clients\": [
                        {
                          \"id\": \"${random_uuid.v2ray_uuid.result}\",
                          \"alterId\": 0
                        }
                      ]
                    },
                    \"streamSettings\": {
                      \"network\": \"tcp\"
                    }
                  }],
                  \"outbounds\": [{
                    \"protocol\": \"freedom\",
                    \"settings\": {}
                  }]
                }
                EOF
                "
              elif [ "$protocol" = "vless" ]; then
                # 创建VLESS配置
                sudo bash -c "cat > /usr/local/etc/v2ray/config.$${protocol}.json <<EOF
                {
                  \"inbounds\": [{
                    \"port\": $${v2ray_port},
                    \"protocol\": \"vless\",
                    \"settings\": {
                      \"clients\": [
                        {
                          \"id\": \"${random_uuid.v2ray_uuid.result}\",
                          \"level\": 0,
                          \"email\": \"user@example.com\"
                        }
                      ],
                      \"decryption\": \"none\"
                    },
                    \"streamSettings\": {
                      \"network\": \"tcp\"
                    }
                  }],
                  \"outbounds\": [{
                    \"protocol\": \"freedom\",
                    \"settings\": {}
                  }]
                }
                EOF
                "
              fi

              # 创建systemd服务配置
              sudo bash -c "cat > /etc/systemd/system/v2ray-$${protocol}.service <<EOF
              [Unit]
              Description=V2Ray Service ($${protocol})
              Documentation=https://www.v2fly.org/
              After=network.target nss-lookup.target

              [Service]
              User=nobody
              CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
              AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
              NoNewPrivileges=true
              ExecStart=/usr/local/bin/v2ray run -config /usr/local/etc/v2ray/config.$${protocol}.json
              Restart=on-failure
              RestartPreventExitStatus=23

              [Install]
              WantedBy=multi-user.target
              EOF
              "

              # 启动服务
              sudo systemctl daemon-reload
              sudo systemctl start v2ray-$${protocol}
              sudo systemctl enable v2ray-$${protocol}
              
              ((v2ray_port++))
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

output "v2ray_connection" {
  value = chomp(join("\n", [
    for idx, protocol in var.protocols : <<EOF
===================== ${protocol} 配置 =====================
协议: ${protocol}
地址: ${aws_instance.instance.public_ip}
端口: ${random_integer.v2ray_port.result + idx}
用户ID: ${random_uuid.v2ray_uuid.result}
${protocol == "vmess" ? "alterId: 0" : ""}
${protocol == "vless" ? "加密方式: none" : ""}
传输协议: tcp
EOF
  ]))
}
