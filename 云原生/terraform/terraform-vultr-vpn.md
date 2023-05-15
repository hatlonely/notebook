# terraform vultr vpn

## 参数获取

```shell
export VULTR_API_KEY=xxx
```

获取地区

```shell
curl -H "Authorization: Bearer ${VULTR_API_KEY}" "https://api.vultr.com/v2/regions" | jq .
```

获取机型

```shell
curl -H "Authorization: Bearer ${VULTR_API_KEY}" "https://api.vultr.com/v2/plans" | jq .
```

获取镜像

```shell
curl -H "Authorization: Bearer ${VULTR_API_KEY}" "https://api.vultr.com/v2/os" | jq .
```

## 参考链接

- [vultra 官网](https://my.vultr.com/)
- [terraform vultra instance](https://registry.terraform.io/providers/vultr/vultr/latest/docs/resources/instance)
