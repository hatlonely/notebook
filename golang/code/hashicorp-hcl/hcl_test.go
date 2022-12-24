package hcl_test

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"testing"

	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclsimple"
	. "github.com/smartystreets/goconvey/convey"
	"github.com/zclconf/go-cty/cty"
	"github.com/zclconf/go-cty/cty/function"
	"github.com/zclconf/go-cty/cty/function/stdlib"
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

func TestExample(t *testing.T) {
	var config Config
	err := hclsimple.DecodeFile("config.hcl", nil, &config)
	if err != nil {
		log.Fatalf("Failed to load configuration: %s", err)
	}
	log.Printf("Configuration is %#v", config)
}

func TestDecodeFile(t *testing.T) {
	Convey("decode config.hcl", t, func() {
		var config Config
		So(hclsimple.DecodeFile("config.hcl", nil, &config), ShouldBeNil)
		So(config, ShouldResemble, Config{
			IOMode: "async",
			Service: ServiceConfig{
				Protocol:   "http",
				Type:       "web_proxy",
				ListenAddr: "127.0.0.1:8080",
				Processes: []ProcessConfig{
					{
						Type: "main",
						Command: []string{
							"/usr/local/bin/awesome-app", "server",
						},
					}, {
						Type: "mgmt",
						Command: []string{
							"/usr/local/bin/awesome-app", "mgmt",
						},
					},
				},
			},
		})
	})
}

func TestStructural(t *testing.T) {
	Convey("decode test.hcl", t, func() {
		So(ioutil.WriteFile("test.hcl", []byte(`
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
`), 0644), ShouldBeNil)
		var config struct {
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

		So(hclsimple.DecodeFile("test.hcl", nil, &config), ShouldBeNil)
		buf, _ := json.MarshalIndent(config, "", "  ")
		So(string(buf), ShouldEqual, `{
  "Key1": "val1",
  "Key2": 2,
  "Key3": [
    1,
    2,
    3
  ],
  "Key4": {
    "key5": "val5"
  },
  "Key6": [
    {
      "Key7": "val7"
    },
    {
      "Key7": "val7"
    }
  ],
  "Key8": {
    "Label1": "label-val1",
    "Label2": "label-val2",
    "Key9": "val9",
    "Key10": {
      "Label3": "label-val3",
      "Key11": "val11",
      "Key12": {
        "Key13": "val13"
      }
    }
  },
  "Key14": "hello\nworld\n"
}`)

		_ = os.RemoveAll("test.hcl")
	})
}

func TestVariable(t *testing.T) {
	Convey("TestExpression", t, func() {
		So(ioutil.WriteFile("test.hcl", []byte(`
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
`), 0644), ShouldBeNil)

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

		So(hclsimple.DecodeFile("test.hcl", &hcl.EvalContext{
			Variables: map[string]cty.Value{
				"a":   cty.NumberIntVal(3),
				"b":   cty.NumberIntVal(6),
				"str": cty.StringVal("world"),
			},
			Functions: nil,
		}, &config), ShouldBeNil)
		buf, _ := json.MarshalIndent(config, "", "  ")
		fmt.Println(string(buf))
		So(string(buf), ShouldEqual, `{
  "Add": 9,
  "Sub": -3,
  "Mul": 18,
  "Div": 2,
  "Mod": 3,
  "Eq": false,
  "Ne": true,
  "Gt": false,
  "Lt": true,
  "Gte": false,
  "Lte": true,
  "And": true,
  "Or": false,
  "Cond": "ne",
  "Concat": "hello world"
}`)
	})
}

func TestFunction(t *testing.T) {
	Convey("TestFunction", t, func() {
		So(ioutil.WriteFile("test.hcl", []byte(`
upper = upper("hello world")
lower = lower("Hello World")
title = title("hello world")
`), 0644), ShouldBeNil)

		var config struct {
			Upper string `hcl:"upper"`
			Lower string `hcl:"lower"`
			Title string `hcl:"title"`
		}

		So(hclsimple.DecodeFile("test.hcl", &hcl.EvalContext{
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
		}, &config), ShouldBeNil)
		buf, _ := json.MarshalIndent(config, "", "  ")
		fmt.Println(string(buf))
		So(string(buf), ShouldEqual, `{
  "Upper": "HELLO WORLD",
  "Lower": "hello world",
  "Title": "Hello World"
}`)
	})
}
