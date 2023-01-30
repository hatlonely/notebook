# 部署 python 基础镜像

1. 创建 lambda 函数文件 `app.py`

```python
#!/usr/bin/env python3

import json


def handler(event, context):
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

2. 创建空的 `requirements.txt`
3. 创建 `Dockerfile`

```dockerfile
FROM public.ecr.aws/lambda/python:3.8

RUN pip3 install --upgrade pip

COPY requirements.txt .
RUN pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

COPY app.py ${LAMBDA_TASK_ROOT}
CMD [ "app.handler" ]
```

4. 创建 `Makefile`

```makefile
NAME ?= aws-lambda-image-python
VERSION ?= 1.0.0
AWS_ACCOUNT_ID = 354292498874
AWS_REGION_ID = ap-southeast-1
REGISTRY ?= ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION_ID}.amazonaws.com

# 制作镜像
image:
	aws ecr get-login-password --region "${AWS_REGION_ID}" | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION_ID}.amazonaws.com
	docker build -t ${REGISTRY}/${NAME}:${VERSION} .

# 提交镜像
push:
	docker push ${REGISTRY}/${NAME}:${VERSION}

# 本地运行
run:
	docker run -ti --rm -p 9000:8080 ${REGISTRY}/${NAME}:${VERSION}

# 本地测试
test:
	@curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"key1":"val1","key2":"val2"}'
```

## 参考链接

- [使用容器镜像部署 Python Lambda 函数](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/python-image.html)
