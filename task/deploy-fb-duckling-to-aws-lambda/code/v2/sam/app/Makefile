NAME ?= aws-lambda-duckling
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
	docker run -ti --rm -p 9000:8000 ${REGISTRY}/${NAME}:${VERSION}

# 本地测试
test:
	echo curl -XPOST https://mlyyjs6bva7sop2hbvaw72wszi0wezea.lambda-url.ap-northeast-2.on.aws/parse --data 'locale=en_GB&text=tomorrow at eight'
