---
title: flutter win11 开发环境搭建
date: "2023-5-6 22:40:12"
tags: ["flutter", "win11", "开发环境"]
categories: ["flutter"]
---

## 安装 Java 11

1. 下载 [jdk-11.0.18 zip 包](https://www.oracle.com/hk/java/technologies/javase/jdk11-archive-downloads.html)（现在需要注册 oracle 账户才可以下载）
2. 解压下载的 zip 包
3. 将解压包的 `bin` 目录添加到环境变量 `PATH` 中
   - 搜索**环境变量**打开系统属性 -> 点击**环境变量** -> 双击**PATH** -> **新建**，填入 `bin` 路径
4. 添加环境变量 `JAVA_HOME` 为解压包路径
   - 搜索**环境变量**打开系统属性 -> 点击**环境变量** -> **新建** -> 填入 `JAVA_HOME` 和解压包路径
5. 检查是否安装成功。打开**cmd**

```shell
C:\Users\hatlo>java --version
java 11.0.18 2023-01-17 LTS
Java(TM) SE Runtime Environment 18.9 (build 11.0.18+9-LTS-195)
Java HotSpot(TM) 64-Bit Server VM 18.9 (build 11.0.18+9-LTS-195, mixed mode)

C:\Users\hatlo>javac --version
javac 11.0.18

C:\Users\hatlo>set java_home
JAVA_HOME=C:\Users\hatlo\develop\java\jdk-11.0.18
```

## 安装 Visual Studio

1. 打开终端，输入命令安装

```shell
winget install --id Microsoft.VisualStudio.2022.Community
```

2. 重新运行 Visual Studio Installer，选择 c++ 开发包重新安装

## 安装 flutter sdk

1. 下载 [flutter sdk 3.17.12](https://storage.flutter-io.cn/flutter_infra_release/releases/stable/windows/flutter_windows_3.7.12-stable.zip)
2. 解压下载的 zip 包
3. 将解压包的 `bin` 目录添加到环境变量 `PATH` 中
   - 搜索**环境变量**打开系统属性 -> 点击**环境变量** -> 双击**PATH** -> **新建**，填入 `bin` 路径
4. 检查是否安装成功。打开**cmd**

```shell
C:\Users\hatlo>dart --version
Dart SDK version: 2.19.6 (stable) (Tue Mar 28 13:41:04 2023 +0000) on "windows_x64"

C:\Users\hatlo>flutter --version
Flutter 3.7.12 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 4d9e56e694 (3 weeks ago) • 2023-04-17 21:47:46 -0400
Engine • revision 1a65d409c7
Tools • Dart 2.19.6 • DevTools 2.20.1
```

## 安装 Android Studio

1. 下载 [Android Studio 安装包](https://developer.android.google.cn/studio)
2. 安装 Android Studio
3. 在 Android Studio 中安装 Andorid SDK，Android SDK Command-line Tools
4. 在插件中搜索 Flutter 插件并安装

## 运行 flutter doctor

运行 flutter doctor，根据提示安装对应的依赖

```text
PS C:\Users\hatlo> flutter doctor
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.7.12, on Microsoft Windows [版本 10.0.22621.1555], locale zh-CN)
[✗] Windows Version (Unable to confirm if installed Windows version is 10 or greater)
[✓] Android toolchain - develop for Android devices (Android SDK version 33.0.2)
[✓] Chrome - develop for the web
[✓] Visual Studio - develop for Windows (Visual Studio Community 2022 17.5.5)
[✓] Android Studio (version 2022.2)
[✓] VS Code (version 1.78.0)
[✓] Connected device (3 available)
```

## 创建 Flutter 项目

1. 打开 Android Studio，创建 Flutter 项目 **New Flutter Project**
2. 制定 flutter 路径
3. 选择 Chrome 设备，直接运行

{% image /images/flutter-win11-开发环境搭建/flutter-demo.png %}

## 常见问题

### 运行 flutter 命令卡主

中国需要设置环境变量 `PUB_HOSTED_URL` 和 `FLUTTER_STORAGE_BASE_URL`，指向国内镜像,[参考](https://docs.flutter.dev/community/china)

```shell
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

## 参考链接

- [flutter 英文官网 Windows 安装](https://docs.flutter.dev/get-started/install/windows)
- [flutter 中文官网 Windows 安装](https://flutter.cn/docs/get-started/install/windows)
