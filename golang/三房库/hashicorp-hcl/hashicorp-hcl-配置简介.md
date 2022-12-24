# hashicorp hcl 配置简介

hcl 是 hashicorp 使用 go 语言开发的结构化配置语言，其语法和 nginx 配置文件的语法类似，并在其基础上支持变量，函数以及表达式。

hcl 也是 terraform 资源编排工具使用的官方语言。

## 官方示例

1. 编写 hcl 配置文件 config.hcl

```hcl
io_mode = "async"

service "http" "web_proxy" {
  listen_addr = "127.0.0.1:8080"
  
  process "main" {
    command = ["/usr/local/bin/awesome-app", "server"]
  }

  process "mgmt" {
    command = ["/usr/local/bin/awesome-app", "mgmt"]
  }
}
```

2. 加载配置文件到结构中

```golang
package main

import (
	"log"

	"github.com/hashicorp/hcl/v2/hclsimple"
)

type Config struct {
	IOMode  string        `hcl:"io_mode"`
	Service ServiceConfig `hcl:"service,block"`
}

type ServiceConfig struct {
	Protocol   string          `hcl:"protocol,label"`
	Type       string          `hcl:"type,label"`
	ListenAddr string          `hcl:"listen_addr"`
	Processes  []ProcessConfig `hcl:"process,block"`
}

type ProcessConfig struct {
	Type    string   `hcl:"type,label"`
	Command []string `hcl:"command"`
}

func main() {
	var config Config
	err := hclsimple.DecodeFile("config.hcl", nil, &config)
	if err != nil {
		log.Fatalf("Failed to load configuration: %s", err)
	}
	log.Printf("Configuration is %#v", config)
}
```

如上面示例所示，`github.com/hashicorp/hcl` 库能将 hcl 配置文件直接加载到 `Config` 结构体中

## 基本结构

test.hcl 文件

```hcl
key1 = "val1"    # 字符串
key2 = 2         # 数值
key3 = [1, 2, 3] # 数组
# 字典
key4 = {
  "key5": "val5"
}
# 对象数组
key6 {
  key7 = "val7"
}
key6 {
  key7 = "val7"
}
# 对象
key8 "label-val1" "label-val2" {
  key9 = "val9"
  # 嵌套对象
  key10 "label-val3" {
    key11 = "val11"
    key12 {
      key13 = "val13"
    }
  }
}
# 多行
key14 = <<EOT
hello
world
EOT
```

其对应的 go 结构如下

```golang
struct {
    Key1 string            `hcl:"key1"`
    Key2 int               `hcl:"key2"`
    Key3 []int             `hcl:"key3"`
    Key4 map[string]string `hcl:"key4"`
    Key6 []struct {
        Key7 string `hcl:"key7"`
    } `hcl:"key6,block"`
    Key8 struct {
        Label1 string `hcl:"label1,label"`
        Label2 string `hcl:"label2,label"`
        Key9   string `hcl:"key9"`
        Key10  struct {
            Label3 string `hcl:"label3,label"`
            Key11  string `hcl:"key11"`
            Key12  struct {
                Key13 string `hcl:"key13"`
            } `hcl:"key12,block"`
        } `hcl:"key10,block"`
    } `hcl:"key8,block"`
    Key14 string `hcl:"key14"`
}
```

hcl 的基本语法主要有两种，一种属性语法（Attribute），一种块语法（Block）

属性语法即 `key = val` 写法。`key` 为标识符，官方使用小写下划线风格；`val` 可以是字符串，数值，布尔，数组和字典。
这些属性和 go 结构体中的公共字段是一一对应的，这种对应关系通过 go 的 tag 语法来指定 `hcl："key1"` 表示该字段来自于配置文件中的 key1 字段。

块语法的形式为 `key label1 label2 ... { sub_block }`。块语法对应的是 go 中的结构体字段，并且在结构体的 tag 中，需要使用 `block` 标识。
块语法中的 `label` 和 `sub_block` 在子结构体中都有相应的字段对应。 其中 `label` 对应结构体中带 `label` 标签的字段，
比如上例中结构体的 `Key8.Label1` 和 `Key8.Label2` 对应的就是配置文件中 `key8` 的两个 `label`；
而 sub_block 则通过 `key` 对应其他字段。

块语法中的这种设计类似于函数参数的位置参数和关键字参数，`label` 相当于位置参数，`sub_block` 相当于关键字参数

相同的 `key` 会被当成数组来解析，如上例中的 `key6` 会被解析成一个结构体数组

## 引入变量

test.hcl 配置文件

```hcl
add = a + b
sub = a - b
mul = a * b
div = b / a
mod = a % b

eq = a == b
ne = a != b
gt = a > b
lt = a < b
gte = a >= b
lte = a <= b
and = (a != b) && (a < b)
or = (a == b) || (a > b)

cond = a == b ? "eq" : "ne"

concat = "hello ${str}"
```

golang 代码

```golang
var config struct {
    Add    int    `hcl:"add"`
    Sub    int    `hcl:"sub"`
    Mul    int    `hcl:"mul"`
    Div    int    `hcl:"div"`
    Mod    int    `hcl:"mod"`
    Eq     bool   `hcl:"eq"`
    Ne     bool   `hcl:"ne"`
    Gt     bool   `hcl:"gt"`
    Lt     bool   `hcl:"lt"`
    Gte    bool   `hcl:"gte"`
    Lte    bool   `hcl:"lte"`
    And    bool   `hcl:"and"`
    Or     bool   `hcl:"or"`
    Cond   string `hcl:"cond"`
    Concat string `hcl:"concat"`
}

hclsimple.DecodeFile("test.hcl", &hcl.EvalContext{
    Variables: map[string]cty.Value{
        "a":   cty.NumberIntVal(3),
        "b":   cty.NumberIntVal(6),
        "str": cty.StringVal("world"),
    },
    Functions: nil,
}, &config)
```

可以的 `hclsimple.DecodeFile` 方法中传入 `hcl.EvalContext` 参数传入变量，这些变量可以在 hcl 配置文件中使用，并用于计算。
支持一般的数值计算和布尔计算；在字符串中可以通过 `${variable}` 引用变量

## 引入函数

test.hcl 配置文件

```hcl
upper = upper("hello world")
lower = lower("Hello World")
title = title("hello world")
```

golang 代码

```golang
var config struct {
    Upper string `hcl:"upper"`
    Lower string `hcl:"lower"`
    Title string `hcl:"title"`
}

hclsimple.DecodeFile("test.hcl", &hcl.EvalContext{
    Variables: nil,
    Functions: map[string]function.Function{
        "upper":       stdlib.UpperFunc,
        "lower":       stdlib.LowerFunc,
        "reverse":     stdlib.ReverseFunc,
        "strlen":      stdlib.StrlenFunc,
        "substr":      stdlib.SubstrFunc,
        "join":        stdlib.JoinFunc,
        "sort":        stdlib.SortFunc,
        "split":       stdlib.SplitFunc,
        "trim":        stdlib.TrimFunc,
        "trim_prefix": stdlib.TrimPrefixFunc,
        "trim_suffix": stdlib.TrimSuffixFunc,
        "trim_space":  stdlib.TrimSpaceFunc,
        "title":       stdlib.TitleFunc,
        "indent":      stdlib.IndentFunc,
        "chomp":       stdlib.ChompFunc,
    },
}, &config)
```

同样在 `hcl.EvalContext` 中可以传入函数，这些函数可以在 hcl 配置文件中使用，在 `github.com/zclconf/go-cty/cty/function/stdlib` 中
定义了一些常用的字符串操作函数，可以直接使用

## 参考链接

- 项目地址: <https://github.com/hashicorp/hcl>
- 语法规则: <https://github.com/hashicorp/hcl/blob/main/hclsyntax/spec.md>
- 测试 case: <https://github.com/hashicorp/hcl/tree/main/specsuite>
