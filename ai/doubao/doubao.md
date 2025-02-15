# 豆包

1. 方舟控制台，创建 API Key

<https://console.volcengine.com/ark/region:ark+cn-beijing/apiKey?apikey=%7B%7D>

```
export ARK_API_KEY="xxx"
```

2. 创建推理点

<https://console.volcengine.com/ark/region:ark+cn-beijing/endpoint?config=%7B%7D>


3. API 调用

```
curl https://ark.cn-beijing.volces.com/api/v3/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ARK_API_KEY>" \
  -d '{
    "model": "<YOUR_ENDPOINT_ID>",
    "messages": [
        {
            "role": "system",
            "content": "You are a helpful assistant."
        },
        {
            "role": "user",
            "content": "Hello!"
        }
    ]
  }'
```

