# docker 常见基础镜像

## scratch

scratch 是一个空镜像，用来制作极小的镜像，比如二进制工具的镜像。编译的时候需要注意使用静态编译，因为 scratch 镜像中没有动态链接库。

```dockerfile
FROM scratch
COPY hello /
CMD ["/hello"]
```

> gcc 添加静态编译参数 `-static`

## busybox

busybox 将一些常用的 unix 命令打包成一个镜像，同时又提供了完整的 posix 环境。其大小只有 4M。

可以进入到容器中执行命令

```sh
docker run -ti --rm busybox
```

目前可用的命令包括

```plain
[, [[, acpid, addgroup, adduser, adjtimex, ar, arp, arping, ash,
awk, basename, beep, blkid, brctl, bunzip2, bzcat, bzip2, cal, cat,
catv, chat, chattr, chgrp, chmod, chown, chpasswd, chpst, chroot,
chrt, chvt, cksum, clear, cmp, comm, cp, cpio, crond, crontab,
cryptpw, cut, date, dc, dd, deallocvt, delgroup, deluser, depmod,
devmem, df, dhcprelay, diff, dirname, dmesg, dnsd, dnsdomainname,
dos2unix, dpkg, du, dumpkmap, dumpleases, echo, ed, egrep, eject,
env, envdir, envuidgid, expand, expr, fakeidentd, false, fbset,
fbsplash, fdflush, fdformat, fdisk, fgrep, find, findfs, flash_lock,
flash_unlock, fold, free, freeramdisk, fsck, fsck.minix, fsync,
ftpd, ftpget, ftpput, fuser, getopt, getty, grep, gunzip, gzip, hd,
hdparm, head, hexdump, hostid, hostname, httpd, hush, hwclock, id,
ifconfig, ifdown, ifenslave, ifplugd, ifup, inetd, init, inotifyd,
insmod, install, ionice, ip, ipaddr, ipcalc, ipcrm, ipcs, iplink,
iproute, iprule, iptunnel, kbd_mode, kill, killall, killall5, klogd,
last, length, less, linux32, linux64, linuxrc, ln, loadfont,
loadkmap, logger, login, logname, logread, losetup, lpd, lpq, lpr,
ls, lsattr, lsmod, lzmacat, lzop, lzopcat, makemime, man, md5sum,
mdev, mesg, microcom, mkdir, mkdosfs, mkfifo, mkfs.minix, mkfs.vfat,
mknod, mkpasswd, mkswap, mktemp, modprobe, more, mount, mountpoint,
mt, mv, nameif, nc, netstat, nice, nmeter, nohup, nslookup, od,
openvt, passwd, patch, pgrep, pidof, ping, ping6, pipe_progress,
pivot_root, pkill, popmaildir, printenv, printf, ps, pscan, pwd,
raidautorun, rdate, rdev, readlink, readprofile, realpath,
reformime, renice, reset, resize, rm, rmdir, rmmod, route, rpm,
rpm2cpio, rtcwake, run-parts, runlevel, runsv, runsvdir, rx, script,
scriptreplay, sed, sendmail, seq, setarch, setconsole, setfont,
setkeycodes, setlogcons, setsid, setuidgid, sh, sha1sum, sha256sum,
sha512sum, showkey, slattach, sleep, softlimit, sort, split,
start-stop-daemon, stat, strings, stty, su, sulogin, sum, sv,
svlogd, swapoff, swapon, switch_root, sync, sysctl, syslogd, tac,
tail, tar, taskset, tcpsvd, tee, telnet, telnetd, test, tftp, tftpd,
time, timeout, top, touch, tr, traceroute, true, tty, ttysize,
udhcpc, udhcpd, udpsvd, umount, uname, uncompress, unexpand, uniq,
unix2dos, unlzma, unlzop, unzip, uptime, usleep, uudecode, uuencode,
vconfig, vi, vlock, volname, watch, watchdog, wc, wget, which, who,
whoami, xargs, yes, zcat, zcip
```

busybox 没有包管理工具。一般直接通过 COPY 命令将二进制文件拷贝到镜像中。

## alpine

apline 是一个围绕 musl libc 和 busybox 构建的轻量级的 linux 发行版，其大小只有 7M。其提供了完整的包管理工具，可以通过 apk 命令安装软件包。

```dockerfile
FROM alpine:3.14
RUN apk add --no-cache mysql-client
ENTRYPOINT ["mysql"]
```

## ubuntu

ubuntu 是一个基于 debian 的 linux 发行版，其大小为 78M。其提供了完整的包管理工具，可以通过 apt 命令安装软件包。

```dockerfile
FROM ubuntu:22.04
RUN apt update && \
    apt install -y --no-install-recommends mysql-client && \
    rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["mysql"]
```

## 参考链接

- [scratch 官方说明](https://hub.docker.com/_/scratch)
- [busybox 官网](https://busybox.net/about.html)
- [busybox 命令列表](https://busybox.net/downloads/BusyBox.html)
- [alipne 用户手册](https://docs.alpinelinux.org/user-handbook/0.1a/index.html)
