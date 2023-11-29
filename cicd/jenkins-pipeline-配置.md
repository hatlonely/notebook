# jenkins pipeline 配置

## Git 提交触发流水线

1. jenkins 安装插件 Gitee。**Manage Jenkins** -> **Manage Plugins** -> **Available** -> **Gitee**
2. jenkins 流水线配置中会看到 **Gitee webhook 构建触发**
3. Gitee 项目中增加 Webhook。进入 Gitee 项目**管理**界面，在 **Webhooks** 中添加。**URL** 和**密码**从第二部中获取。配置完成后点击测试，会报 404 是正常的。

## 常见错误

### git 报错 not in a git directory

首次会有报错提示，说需要设置 `git config --global --add safe.directory`。这是新版本的 git 要求信任目录，需要设置信任目录，否则会报错。执行 `git config --global --add safe.directory '*'` 即可。

```groovy

## 参考链接

- [jenkins gitee 插件](https://plugins.jenkins.io/gitee/)
```
