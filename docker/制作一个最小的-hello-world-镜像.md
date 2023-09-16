# 制作一个最小的 hello world 镜像

1. 创建源文件 `hello-world.c`

```c
#include <stdio.h>

int main()
{
    printf("Hello World\n");
    return 0;
}
```

2. 创建 `Dockerfile`

使用 gcc 镜像作为编译镜像，编译处二进制之后，拷贝到 scratch 镜像中，scratch 镜像是一个空镜像，只包含最基础的文件系统，这样就可以创建一个最小的镜像了。

```dockerfile
FROM gcc AS builder

COPY helloworld.c /code/helloworld.c
RUN gcc -static -o /code/helloworld /code/helloworld.c

FROM scratch

COPY --from=builder /code/helloworld /
ENTRYPOINT [ "/helloworld" ]
```

> 注意 gcc 编译需要加 -static 选项，否则依赖动态链接库，无法运行

3. 构建镜像

```sh
docker build . -t helloworld

# 查看镜像，镜像大小不到 1M
docker image ls | grep helloworld
```

4. 运行镜像

```sh
docker run helloworld
```

## 总结

这里使用 gcc 制作镜像，需要静态链接 c 标准库，否则运行时会报错，因为 scratch 镜像中没有 c 标准库，但也因此增加了镜像的体积，而官方的 hello-world 镜像只有十几k，还是有不小的差距。

## 参考链接

- [Dockerfile 最佳实践](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [gcc 镜像](https://hub.docker.com/_/gcc)
- [docker build 基础镜像](https://docs.docker.com/build/building/base-images/)
