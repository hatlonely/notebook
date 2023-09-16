# zsh 配置

## 安装 oh my zsh

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

或者

```shell
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

## 配置历史命令提示

1. 下载插件

```shell
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

2. 配置 zsh 插件。 `vim ~/.zshrc` 设置 plugins

```shell
plugins=(git zsh-autosuggestions)
```

## 配置高亮

1. 下载插件

```shell
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

2. 配置 zsh 插件。 `vim ~/.zshrc` 设置 plugins

```shell
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
```

## 参考链接

- [oh my zsh 官网](https://ohmyz.sh/)