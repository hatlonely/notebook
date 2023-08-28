# terraform 自定义 provider 开发官方样例

## 本地启动测试服务

```shell
git clone https://github.com/hashicorp/learn-terraform-hashicups-provider && cd learn-terraform-hashicups-provider
cd docker_compose && docker compose up
```

验证服务启动

```shell
curl localhost:19090/health
```

## 编译开发包

```shell
git clone https://github.com/hashicorp/terraform-provider-hashicups && cd terraform-provider-hashicups
go mod tidy
make install
```

## 测试代码

```shell
cd terraform-provider-hashicups/examples

terraform init
terraform apply
```

## 参考链接

- [Call APIs with Custom SDK Providers](https://developer.hashicorp.com/terraform/tutorials/providers)
- [Perform CRUD operations with providers](https://developer.hashicorp.com/terraform/tutorials/providers/provider-use)
- [learn-terraform-hashicups-provider](https://github.com/hashicorp/learn-terraform-hashicups-provider)
