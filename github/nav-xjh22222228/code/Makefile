NAME = nav
VERSION = 1.0.0
REGISTRY_ENDPOINT ?= registry.cn-shanghai.aliyuncs.com
REGISTRY_USERNAME ?= hatlonely
REGISTRY_PASSWORD ?= 123456
REGISTRY_NAMESPACE ?= hatlonely

.PHONY: image
image:
	docker build -t ${REGISTRY_ENDPOINT}/${REGISTRY_NAMESPACE}/${NAME}:${VERSION} .

.PHONY: push
push:
	docker login --username=${REGISTRY_USERNAME} --password=${REGISTRY_PASSWORD} ${REGISTRY_ENDPOINT}
	docker push ${REGISTRY_ENDPOINT}/${REGISTRY_NAMESPACE}/${NAME}:${VERSION}
