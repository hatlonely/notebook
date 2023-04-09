# Mac 制作装机 U 盘

1. 找到 U 盘设备

```shell
diskutil list | grep external
```

2. 卸载 U 盘设备

```shell
diskutil unmountDisk /dev/disk3
```

3. 将准备好的 iso 文件刻录到 U 盘中（该方法不能制作 windows 安装 U 盘）

deepin 桌面版: <https://www.deepin.org/zh/download/>

```shell
sudo dd if=deepin-desktop-community-20.8-amd64.iso of=/dev/disk3 bs=1M; sync
```

ubuntu 服务器版: <https://cn.ubuntu.com/download/server/step1>

```shell
sudo dd if=ubuntu-22.04.2-live-server-amd64.iso of=/dev/disk3 bs=1M; sync
```

4. 推出 U 盘

```shell
diskutil eject /dev/disk3
```
