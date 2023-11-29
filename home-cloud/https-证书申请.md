# https 证书申请

## 证书申请

1. 申请证书

```shell
docker run -it --rm \
    --name certbot \
    -v $(pwd)/letsencrypt:/etc/letsencrypt \
    -v $(pwd)/letsencrypt-bk:/var/lib/letsencrypt \
    certbot/certbot \
    certonly --manual --agree-tos \
    --server https://acme-v02.api.letsencrypt.org/directory \
    --preferred-challenges dns \
    -d "*.hatlonely.com"
```

2. 根据提示添加 TXT 解析，域名 `_acme-challenge.hatlonely.com.`
3. 等待 ttl 解析成功，<https://toolbox.googleapps.com/apps/dig/#TXT/_acme-challenge.hatlonely.com.>
4. 解析成功之后，证书保存在 letsencrypt 目录

> 文件权限比较严格，在 wsl 需要 root 才能访问
> 证书文件: `letsencrypt/live/hatlonely.com/fullchain1.pem`
> 私钥文件: `letsencrypt/live/hatlonely.com/privkey1.pem`

## 参考链接

- 申请 Let'sEncrypt 证书: <https://www.cnblogs.com/haoee/p/16284491.html>
