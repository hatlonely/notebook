# 部署 python zip 包

1. 创建 lambda 函数文件 `lambda_function.py`

```python
#!/usr/bin/env python3

import json


def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "event": event,
        })
    }
```

2. 创建 `Makefile`

```makefile
NAME ?= test-lambda-zip

# 制作 zip 包
zip:
	zip ${NAME}.zip lambda_function.py

# 更新函数代码。需要提前在控制台创建函数
deploy:
	aws lambda update-function-code --function-name ${NAME} --zip-file fileb://${NAME}.zip
```

## 参考链接

- [使用 .zip 文件归档部署 Python Lambda 函数](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/python-package.html)
