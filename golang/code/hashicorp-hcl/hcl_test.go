package hcl_test

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"os"
	"testing"

	"github.com/hashicorp/hcl/v2/hclsimple"
	. "github.com/smartystreets/goconvey/convey"
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
key1 = "val1"
key2 = 2
key3 = [1, 2, 3]
key4 = {
  "key5": "val5"
}
key6 {
  key7 = "val7"
}
key6 {
  key7 = "val7"
}

key8 "label-val1" "label-val2" {
  key9 = "val9"
  key10 "label-val3" {
    key11 = "val11"
    key12 {
      key13 = "val13"
    }
  }
}
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
  }
}`)

		_ = os.RemoveAll("test.hcl")
	})
}
