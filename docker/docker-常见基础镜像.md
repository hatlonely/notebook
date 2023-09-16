# docker 常见基础镜像

## scratch

```dockerfile
FROM scratch
COPY hello /
CMD ["/hello"]
```

空镜像，用来制作极小的镜像，比如二进制工具的镜像。编译的时候需要注意使用静态编译，因为 scratch 镜像中没有动态链接库。

gcc 添加静态编译参数 `-static`

## 参考链接

- [scratch 官方说明](https://hub.docker.com/_/scratch)
