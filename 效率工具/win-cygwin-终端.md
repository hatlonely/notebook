# win cygwin 终端

cygwin 是 windows 下兼容 unix 命令的终端，默认提供 bash，可以安装 zsh，可以直接集成在 Jetbrains 中。

PS: 试了一下 wsl/git bash/msys2/cygwin，最后还是选择了 cygwin，因为 cygwin 可以直接集成在 Jetbrains 中，而且可以直接使用 windows 的文件系统，不需要像 wsl 那样需要挂载，关键是 wsl 的 bug 还比较多，体验很差。

## cygwin 安装

1. 下载 cygwin 安装包 <https://cygwin.com/setup-x86_64.exe>
2. 在下载目录打开终端，输入如下命令安装

```shell
C:\Users\Admin\Downloads\setup-x86_64.exe --no-admin -q -P wget,tar,git,nano,vim,iconv
```

3. 设置 `UTF-8` 编码。打开安装好的 cygwin 终端，右键 `Options` -> `Text` -> `Locale`，设置 `Locale` 为 `zh_CN`，`Character set` 为 `UTF-8`
4. 安装包管理工具 apt-cyg。打开安装好的 cygwin 终端，执行如下命令

```shell
wget https://raw.githubusercontent.com/transcode-open/apt-cyg/master/apt-cyg > apt-cyg
install apt-cyg /bin
```

## 安装 zsh

1. 打开 cygwin 终端，执行如下命令安装 zsh

```shell
apt-cyg install zsh
```

2. 安装 zsh 主题，oh my zsh

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

3. 设置 zsh 编码（默认中文显示会是乱码，需要配置语言）

```shell
echo "export LANG=zh_CN.UTF-8" >> ~/.zshrc
```

4. 设置 zsh 主题

```shell
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/g' ~/.zshrc
```

## Jetbrains 配置

1. 打开 Jetbrains，打开 Settings -> Tools -> Terminal
2. 设置 Shell path 为 `C:\cygwin64\bin\zsh.exe`
3. 搜索 `encoding` 所有能设置的选项都设置为 `UTF-8` （否则可能会有乱码）

## 参考链接

- [cygwin 官网](https://cygwin.com/setup-x86_64.exe)
