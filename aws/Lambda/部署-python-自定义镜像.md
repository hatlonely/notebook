# 部署 python 自定义镜像

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
3. 创建 docker 入口文件 `lambda-entrypoint.sh`

```shell
#!/bin/sh

if [ -z "${AWS_LAMBDA_RUNTIME_API}" ]; then
    exec /usr/bin/aws-lambda-rie /usr/local/bin/python3 -m awslambdaric $1
else
    exec /usr/local/bin/python3 -m awslambdaric $1
fi
```

4. 创建 `Dockerfile`

```dockerfile
ARG LAMBDA_TASK_ROOT="/var/task"

FROM python:3.9
ARG LAMBDA_TASK_ROOT
RUN pip3 install --upgrade pip
RUN pip3 install awslambdaric --target ${LAMBDA_TASK_ROOT}

ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/bin/aws-lambda-rie
RUN chmod +x /usr/bin/aws-lambda-rie

WORKDIR /var/task
COPY requirements.txt .
RUN pip3 install -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

COPY app.py ${LAMBDA_TASK_ROOT}
COPY lambda-entrypoint.sh /lambda-entrypoint.sh
CMD [ "app.handler" ]
ENTRYPOINT [ "/lambda-entrypoint.sh" ]
```

5. 创建 `Makefile`

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

- [使用容器镜像部署 Python Lambda 函数](https://docs.aws.amazon.com/zh_cn/lambda/latest/dg/python-image.html#python-image-clients)
- [New for AWS Lambda – Container Image Support](https://aws.amazon.com/cn/blogs/aws/new-for-aws-lambda-container-image-support/)
