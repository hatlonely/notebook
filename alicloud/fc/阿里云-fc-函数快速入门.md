# 阿里云 fc 函数快速入门

## 快速入门

1. 安装 serverless-devs 工具

```
sudo apt install -y nodejs
sudo apt install -y npm

sudo npm install -g @serverless-devs/s
```

2. 创建秘钥。[访问控制](https://ram.console.aliyun.com/overview)创建用户获取秘钥，病授予用户 AliyunFCFullAccess 权限
3. 配置秘钥

```
s config add
```

4. 创建项目

```
s init devsapp/start-fc-http-python3
```

修改 `code/index.py` 中的代码,即可修改函数逻辑

5. 本地启动

```
s local start
```

启动成功后，打开 url 即可访问


6. 部署

```
s deploy
```

部署成功后，打开 url 即可访问

7. 移除

```
s remove
```

## 部署目标检测函数

1. 创建 oss bucket
2. 授予 AliyunFcDefaultRole 角色 AliyunOSSFullAccess 权限
3. 创建项目
    - RAM 角色： acs:ram::150**********543:role/aliyunfcdefaultrole
    - OSS 触发器角色： acs:ram::150**********543:role/aliyunosseventnotificationrole

```
s init devsapp/image-prediction-app
```

报错 tensorflow 版本不匹配



## 参考链接

- [阿里云函数计算组件文档](https://docs.serverless-devs.com/fc/config)
