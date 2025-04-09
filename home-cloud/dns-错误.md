
```
 > [2/5] RUN apk add --no-cache curl openssl socat tzdata bash jq     && curl https://get.acme.sh | sh     && ln -s /root/.acme.sh/acme.sh /usr/local/bin/acme.sh:                                                                                        
0.142 fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/main/x86_64/APKINDEX.tar.gz                                          
5.148 WARNING: fetching https://dl-cdn.alpinelinux.org/alpine/v3.21/main: temporary error (try again later)
5.148 fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/community/x86_64/APKINDEX.tar.gz
10.15 WARNING: fetching https://dl-cdn.alpinelinux.org/alpine/v3.21/community: temporary error (try again later)
10.15 ERROR: unable to select packages:
10.15   bash (no such package):
10.15     required by: world[bash]
10.15   curl (no such package):
10.15     required by: world[curl]
10.15   jq (no such package):
10.15     required by: world[jq]
10.15   openssl (no such package):
10.15     required by: world[openssl]
10.15   socat (no such package):
10.15     required by: world[socat]
10.15   tzdata (no such package):
10.15     required by: world[tzdata]
```

这个错误是DNS错误，将 DNS 设置为 114.114.114.114 或者 223.5.5.5 就可以了，不清楚具体原因。