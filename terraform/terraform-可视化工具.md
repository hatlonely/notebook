# terraform 资源可视化工具

## terraform graph 命令（不推荐）

```shell
sudo apt install graphviz

terraform graph | dot -Tpng > graph.png
```

效果比较差，很乱，基本没法看

## terraform Visual（不推荐）

用如下命令生成 json 文件后，上传到 <https://hieven.github.io/terraform-visual/> 即可

```shell
terraform plan -out=plan.out
terraform show -json plan.out > plan.json
```

资源平铺的方式，资源比较多得情况下太长了，并且丢失了资源之间的关系，也不理想

## inframap（不推荐）

1. 安装

```shell
git clone https://github.com/cycloidio/inframap
cd inframap
go mod download
make build

sudo mv inframap /usr/local/bin/
```

2. 安装依赖工具 graph-easy（非必要）

```shell
sudo apt install libgraph-easy-perl
```

3. 生成图片

```shell
inframap generate . | dot -Tpng > graph.png
```

- aws google 等云厂商，直接集成了他们图标，这一点比较好
- 比 terraform graph 命令生成的简洁一点，但是整体也还是没法看
- random 库会报错，必须要部署之后才能根据 state 文件看到架构
- 有一些资源会被忽略掉

## rover（不推荐）

```shell
printenv | grep "AWS" > .env
docker run --rm -it -p 9000:9000 -v "$(pwd):/src" --env-file ./.env im2nguyen/rover
```

- 强制矩阵排列，视觉上规整了一些，但是线完全重叠在了一起，也没法看
- 不支持阿里云

## blast radius（不推荐）

```shell
docker run --rm -it -p 5000:5000 \
  -v $(pwd):/data:ro \
  --security-opt apparmor:unconfined \
  --cap-add=SYS_ADMIN \
  28mm/blast-radius
```

项目地址也的效果没有跑出来，排列也不规整，也没有颜色区分，感觉像是一个阉割版本。
运行的时候，也有很多报错，可能是长时间没有更新，terraform 有更新，不兼容了。

## 结论

目前来看，没有一个工具在可视化方面做得很好。可能 terraform 本身资源的关系就比较复杂，可视化也比较困难。
另外 terraform 本身的更新迭代速度也比较快，社区没有持续维护的项目。

## 参考资料

- [Best Tools to Visualize your Terraform](https://blog.brainboard.co/best-tools-to-visualize-your-terraform-d4b537f091dc)
- [inframap 项目地址](https://github.com/cycloidio/inframap)
- [rover 项目地址](https://github.com/im2nguyen/rover)
- [blast radius 项目地址](https://github.com/28mm/blast-radius)
