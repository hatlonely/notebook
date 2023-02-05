# terraform provider docker

`kreuzwerker/docker` 提供了对 docker 资源的管理

- `docker_image`: 从镜像仓库获取镜像 `docker pull`
- `docker_registry_image`: 推送镜像到镜像仓库，类似 `docker push`
- `docker_container`: 创建 docker 容器

## 参考代码

```terraform
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}

provider "docker" {}

resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_container" "nginx" {
  name  = "nginx"
  image = docker_image.nginx.image_id
  ports {
    internal = 80
    external = 80
  }
}
```

## 参考链接

- [api 文档](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)
- [完整代码](code/docker/main.tf)
