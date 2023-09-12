# win11 power shell

## 安装 oh-my-posh

1. 安装

```powershell
winget install JanDeDobbeleer.OhMyPosh -s winget
```

2. 新增配置文件

```shell
notepad $PROFILE
```

3. 配置文件内容

```powershell
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\cert.omp.json" | Invoke-Expression
```

## 参考链接

- [oh my posh 官网文档](https://ohmyposh.dev/docs/installation/windows)
- [主题列表](https://ohmyposh.dev/docs/themes)