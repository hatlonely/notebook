# AWS Shadowsocks Terraform 脚本分析

这个文档分析了 `vpn.tf` 脚本的功能，包括创建的资源、自动执行的脚本以及输出信息。

## 主要功能

此Terraform脚本自动在AWS上创建一个运行Shadowsocks服务的VPN服务器。

## 创建的资源

1. **AWS基础设施**:
   - VPC (Virtual Private Cloud): 创建私有网络空间，CIDR块为10.0.0.0/16
   - 子网: 在ap-southeast-1a可用区创建子网，CIDR块为10.0.1.0/24
   - 互联网网关: 用于连接VPC到互联网
   - 路由表: 配置网络流量路由
   - 路由表关联: 将路由表与子网关联

2. **安全资源**:
   - TLS私钥: 生成RSA 4096位密钥对
   - 本地密钥文件: 将生成的密钥保存到本地文件系统(id_rsa和id_rsa.pub)
   - AWS密钥对: 将公钥导入到AWS
   - 安全组: 配置防火墙规则，允许SSH(端口22)和Shadowsocks随机端口的流量

3. **计算资源**:
   - EC2实例: 创建一个t2.micro实例，运行Ubuntu 22.04
   - SSM文档: 创建用于初始化实例的命令文档
   - SSM关联: 将命令文档与EC2实例关联，执行初始化

4. **随机资源**:
   - 随机密码: 为Shadowsocks服务生成16位密码
   - 随机端口: 为Shadowsocks服务生成随机端口(20000-60000范围)

## 自动执行的脚本

启动脚本通过AWS SSM(Systems Manager)执行，主要包含以下操作：

1. **网络优化**:
   - 系统参数优化，修改 `/etc/sysctl.d/local.conf` 文件
   - 调整TCP相关参数以优化网络性能
   - 配置拥塞控制算法为hybla(适用于高延迟网络)

2. **Shadowsocks安装与配置**:
   - 更新软件包并安装shadowsocks-libev
   - 禁用默认服务
   - 为每种加密方法创建单独的配置文件：
     - 创建 `/etc/shadowsocks-libev/config.[encryption_method].json` 配置文件
     - 设置端口、密码、加密方法等
   - 为每种加密方法创建systemd服务：
     - 创建 `/etc/systemd/system/shadowsocks-libev-[encryption_method].service` 服务文件
     - 配置服务自动启动并设置重启策略
   - 启动并启用所有Shadowsocks服务

## 输出信息

脚本执行完成后，提供以下输出：

1. **SSH连接信息**:
   - 显示用于SSH连接到服务器的命令，包括密钥文件和IP地址

2. **Shadowsocks连接信息**:
   - 为每种加密方法显示连接参数：
     - 主机IP地址
     - 端口号(为每种加密方法分配不同端口)
     - 密码
     - 加密方法

## 参数化配置

脚本通过变量允许自定义：
- 资源命名前缀(默认为"ss")
- 支持的加密方法列表(默认支持三种加密方法：aes-256-gcm、aes-256-ctr和chacha20-ietf-poly1305)
