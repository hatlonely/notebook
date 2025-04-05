# AWS V2Ray Terraform 脚本

本脚本自动在AWS上创建并配置运行V2Ray服务的VPN服务器。

## 主要功能

此Terraform脚本自动在AWS上创建一个运行V2Ray服务的VPN服务器，支持多种代理协议（默认为VMess和VLESS）。

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
   - 安全组: 配置防火墙规则，允许SSH(端口22)和V2Ray随机端口的流量

3. **计算资源**:
   - EC2实例: 创建一个t2.micro实例，运行最新的Ubuntu 22.04
   - SSM文档: 创建用于初始化实例的命令文档
   - SSM关联: 将命令文档与EC2实例关联，执行初始化

4. **随机资源**:
   - 随机UUID: 为V2Ray服务生成用户ID
   - 随机端口: 为V2Ray服务生成随机端口(20000-60000范围)

## 自动执行的脚本

启动脚本通过AWS SSM(Systems Manager)执行，主要包含以下操作：

1. **网络优化**:
   - 系统参数优化，修改 `/etc/sysctl.d/local.conf` 文件
   - 调整TCP相关参数以优化网络性能
   - 配置拥塞控制算法为hybla(适用于高延迟网络)

2. **V2Ray安装与配置**:
   - 更新软件包并安装必要依赖
   - 下载并执行V2Ray官方安装脚本
   - 为每种协议创建单独的配置文件：
     - 创建 `/usr/local/etc/v2ray/config.[protocol].json` 配置文件
     - 设置端口、用户ID等
   - 为每种协议创建systemd服务：
     - 创建 `/etc/systemd/system/v2ray-[protocol].service` 服务文件
     - 配置服务自动启动并设置重启策略
   - 启动并启用所有V2Ray服务

## 输出信息

脚本执行完成后，提供以下输出：

1. **SSH连接信息**:
   - 显示用于SSH连接到服务器的命令，包括密钥文件和IP地址

2. **V2Ray连接信息**:
   - 为每种协议显示连接参数：
     - 协议类型(VMess或VLESS)
     - 主机IP地址
     - 端口号(为每种协议分配不同端口)
     - 用户ID(UUID)
     - 其他协议特定参数(如alterId等)
     - 传输协议设置

## 参数化配置

脚本通过变量允许自定义：
- 资源命名前缀(默认为"v2ray")
- 支持的协议列表(默认支持VMess和VLESS两种协议)

## 使用方法

1. 确保已安装Terraform
2. 克隆仓库并进入脚本目录
3. 初始化Terraform: `terraform init`
4. 应用Terraform配置: `terraform apply`
5. 按照输出的信息配置V2Ray客户端

## 注意事项

- 此脚本默认部署在新加坡区域(ap-southeast-1)
- 生成的密钥文件会保存在本地目录中
- 服务器使用t2.micro实例类型，符合AWS免费套餐
