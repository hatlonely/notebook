# docker

普通用户访问 docker 需要加入 docker 用户组

1. 确认 Docker 安装：确保系统上已经安装了 Docker。
2. 检查或创建 docker 组：使用 `grep docker /etc/group` 命令检查是否已有 docker 组，若不存在，则使用 `sudo groupadd docker`命令创建。
3. 将用户添加到 docker 组：执行 `sudo usermod -aG docker <username>`，将普通用户添加到 docker 组。
4. 更新生效：注销并重新登录或重启系统，使组成员身份生效
