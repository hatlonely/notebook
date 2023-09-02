# terraform 资源可视化工具

## Terraform graph 命令

```shell
sudo apt install graphviz

terraform graph | dot -Tpng > graph.png
```

效果比较差，很乱，基本没法看

## Terraform Visual

用如下命令生成 json 文件后，上传到 <https://hieven.github.io/terraform-visual/> 即可

```shell
terraform plan -out=plan.out
terraform show -json plan.out > plan.json
```

资源平铺的方式，资源比较多得情况下太长了，并且丢失了资源之间的关系，也不理想

## inframap

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

比 terraform graph 命令生成的简洁一点，但是整体也还是没法看

##  

## 参考资料

- [Best Tools to Visualize your Terraform](https://blog.brainboard.co/best-tools-to-visualize-your-terraform-d4b537f091dc)
- [inframap 项目地址](https://github.com/cycloidio/inframap)
