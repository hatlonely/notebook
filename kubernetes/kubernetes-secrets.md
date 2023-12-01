# kubernetes secrets

## docker 秘钥

```shell
# 创建一个 docker 秘钥
kubectl create secret docker-registry my-pull-secret \
  --docker-email=hatlonely@foxmail.com \
  --docker-username=hatlonely \
  --docker-password=123456 \
  --docker-server=registry.cn-shanghai.aliyuncs.com

# 等效于

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: my-pull-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: |
    $(echo '{
  "auths": {
    "registry.cn-shanghai.aliyuncs.com": {
      "username": "hatlonely",
      "password": "123455",
      "email": "hatlonely@foxmail.com",
      "auth": "aGF0bG9uZWx5OjEyMzQ1NQ=="
    }
  }
}' | base64 -w 0)
EOF

# 获取 docker 秘钥
kubectl get secret my-pull-secret -o yaml
kubectl get secret my-pull-secret -o=jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq .

# 删除 docker 秘钥
kubectl delete secret my-pull-secret
```

## 通用秘钥

```shell
# 创建一个通用秘钥
kubectl create secret generic mysql-admin \
    --from-literal=username=admin \
    --from-literal=password='12345'

# 等效于
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: mysql-admin
type: Opaque
data:
  username: $(echo "admin" | base64 -d)
  password: $(echo "12345" | base64 -d)
EOF

# 获取秘钥
kubectl get secret mysql-admin -o yaml
kubectl get secret mysql-admin -o=jsonpath='{.data.username}' | base64 -d
kubectl get secret mysql-admin -o=jsonpath='{.data.password}' | base64 -d

# 删除秘钥
kubectl delete secret mysql-admin
```

从文件中创建任意秘钥，`--from-file` 的 key 为文件名，value 为文件内容

```shell
cat > secret.txt <<EOF
mysql:
  username: admin
  password: 12345
EOF

kubectl create secret generic mysql-admin --from-file=secret.txt
```

## 参考链接

- [k8s 官网文档](https://kubernetes.io/docs/concepts/configuration/secret/)
