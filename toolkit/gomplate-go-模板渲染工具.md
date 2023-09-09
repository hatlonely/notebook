# gomplate go 模板渲染工具

gomplate 是一个使用 go 语言开发的模板渲染工具，可以动态用来生成一些文件。

## 安装

### mac

```shell
brew install gomplate
```

### windows

```shell
choco install gomplate
```

### go

```shell
go install github.com/hairyhenderson/gomplate/v4/cmd/gomplate@latest
gomplate --help
...
```

## 快速入门

1. 用环境变量中渲染标准输入

```shell
echo "Hello, {{.Env.USER}}" | gomplate
```

2. 用环境变量渲染文件

```shell
cat > 1.txt.gotpl << EOF
Hello, {{.Env.USER}}
EOF

gomplate -f 1.txt.gotpl

rm -rf 1.txt.gotpl
```

3. 用文件渲染文件

```shell
cat >var1.yaml <<EOF
key1: 1
key2: val2
EOF

cat >var2.yaml <<EOF
key3:
  - val3
  - val4
EOF

cat >1.txt.gotpl <<EOF
Hello, {{.Env.USER}}

key1 = {{ .var1.key1 }}
key2 = {{ .var1.key2 }}
{{- range \$i, \$e := $.var2.key3 }}
key3[{{ \$i }}] = {{ \$e }}
{{- end }}
EOF

gomplate -f 1.txt.gotpl -c var1=var1.yaml -c var2=var2.yaml

rm -rf 1.txt.gotpl
```

4. 渲染目录

```shell
mkdir -p tpls

cat >tpls/1.txt <<EOF
hello {{ .Env.USER }}
EOF

cat >tpls/2.txt <<EOF
hello {{ .Env.USER }}
EOF

gomplate --input-dir tpls --output-dir out

rm -rf tpls out
```

## 参考链接

- [官网主页](https://docs.gomplate.ca/)
- [项目地址](https://github.com/hairyhenderson/gomplate)
- [go 模板语法](https://pkg.go.dev/text/template)
