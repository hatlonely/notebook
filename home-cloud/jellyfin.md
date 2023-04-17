# jellyfin

## 硬件加速（设置完了，但是好像并没有用）

CPU 型号: i7-10700，支持 Quick Sync Video，CPU
详情 <https://ark.intel.com/content/www/us/en/ark/products/199316/intel-core-i710700-processor-16m-cache-up-to-4-80-ghz.html>

主机安装显卡驱动

```shell
wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | sudo apt-key add -
sudo apt-add-repository 'deb [arch=amd64] https://repositories.intel.com/graphics/ubuntu focal main'
sudo apt update -y
sudo apt install -y intel-media-va-driver-non-free
```

mount 进容器

```shell
extraVolumes:
  - name: dri
    hostPath:
      path: /usr/lib/x86_64-linux-gnu/dri
      type: Directory

extraVolumeMounts:
  - name: dri
    mountPath: /dev/dri
```

进入 jellyfin 控制台 -> 播放 -> 硬件加速，设置开启硬件加速（开启之后无法播放 hevc），未定位到原因

## 参考链接

- jellyfin docker 配置: <https://docs.linuxserver.io/images/docker-jellyfin>
- k8s volumes: <https://kubernetes.io/docs/concepts/storage/volumes/>
- ubuntu
  显卡驱动: <https://www.reddit.com/r/jellyfin/comments/mjwup8/comment/gtcrz0o/?utm_source=share&utm_medium=web2x&context=3>
