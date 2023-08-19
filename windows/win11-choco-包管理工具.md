# win11 choco 包管理工具

## 安装

1. 按 `win` 键搜索应用，输入 `powershell`，以管理员身份运行命令提示符
2. 依次执行如下命令

```shell
Get-ExecutionPolicy

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

3. 输入 `choco`，如果出现如下提示，则安装成功

```shell
Chocolatey v2.2.2
Please run 'choco -?' or 'choco <command> -?' for help menu.
```

## 软件安装

同样需要以管理员身份在 `powershell` 中执行如下命令

```shell
choco install terraform
```
