# 查看外网 ip

## cip.cc

```shell
curl cip.cc

# 提取公网 ip
curl -s cip.cc | grep URL | awk '{print $3}' | awk -F '/' '{print $NF}'
```
