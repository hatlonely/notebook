# 制作 golang 二进制工具镜像

1. 创建源文件 `helloworld.go`

```go
package main

import "fmt"

func main() {
	fmt.Println("Hello World!")
}
```

2. 创建 `Dockerfile`

```dockerfile
FROM golang:1.18 AS builder

COPY helloworld.go /code/helloworld.go
RUN go build -o /code/helloworld /code/helloworld.go

FROM scratch

COPY --from=builder /code/helloworld /
ENTRYPOINT [ "/helloworld" ]
```

> go build 会自动静态编译，所以不需要额外的参数。

3. 构建镜像

```sh
docker build . -t helloworld

# 查看镜像，镜像大小不到 2M
docker image ls | grep helloworld
```

4. 运行镜像

```sh
docker run helloworld
```
