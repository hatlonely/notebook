## vscode 配置

## 快捷键

### windows

运行命令: `ctrl + shift + p`
快速搜索: `ctrl + p`
打开设置: `ctrl + ，`

## 外观

### 产品主题

1. 安装插件 `MacOS Modern Theme`。macos 风格的界面

### 颜色主题

1. 安装插件 `Material Theme`
2. 安装插件 `Andromeda`
3. 安装插件 `Omni Theme`

### 图标主题

1. 安装插件 `Material Icon Theme`

### 字体切换

1. 安装插件 `Font Switcher`
2. `ctrl + shift + p` 打开命令面板
3. 输入 `switch font` 切换字体

### 中文

1. 安装插件 `Chinese (Simplified) Language Pack for Visual Studio Code`

## 编辑器

### 自动折行

1. 打开设置
2. 设置自动折行 `"editor.wordWrap": "bounded"`
3. 自动折行列数 `"editor.wordWrapColumn": 120`

### 保存时自动格式化

1. 配置保存时自动格式化

```json
"editor.formatOnSave": true
```

2. 搜索并安装各个语言对应的格式化插件
3. 在配置中增加各个语言的格式化配置，以 python 为例：

```json
"[python]": {
  "editor.defaultFormatter": "ms-python.black-formatter",
}
```

## 终端

### 选中复制

1. 打开设置
2. 搜索 `selection`
3. 勾选 `terminal.integrated.copyOnSelection`

## python

1. 打开插件，安装 Python 插件

> 如果代码中有库缺失，会导致测试插件无法检测到测试用例，手动安装缺失库之后可以解决

2. 安装插件 Black Formatter 用于格式化代码。安装完成后在 setting 中增加如下配置

```json
"[python]": {
  "editor.defaultFormatter": "ms-python.black-formatter",
  "editor.formatOnSave": true
}
```

## git

1. 安装插件 `Auto Commit Message`。点击图标即可自动添加 commit message
2. 安装插件 `Git Graph` 插件。可以查看 git 历史记录

## 参考链接

- [vscode python 开发文档](https://code.visualstudio.com/docs/python/testing)
- [vscode 主题](https://vscodethemes.com/)
