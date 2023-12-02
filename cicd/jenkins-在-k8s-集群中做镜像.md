# jenkins kubernetes agent

使用官网的 helm 在 k8s 中安装 jenkins 后，可以直接使用 k8s agent 来执行 pipeline。

```groovy
pipeline {
    agent {
        kubernetes {
            cloud "kubernetes"
            defaultContainer 'jnlp'
            yaml """
apiVersion: "v1"
kind: "Pod"
spec:
  containers:
  - image: "registry.cn-shanghai.aliyuncs.com/hatlonely/docker:25-rc-git"
    imagePullPolicy: "IfNotPresent"
    name: "docker"
    envFrom:
    - secretRef:
        name: go-test-ci
    resources: {}
    securityContext:
      privileged: true
    tty: false
    volumeMounts:
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
      readOnly: false
    workingDir: "/home/jenkins/agent"
  hostNetwork: false
  imagePullSecrets:
  - name: "hatlonely-pull-secret"
  nodeSelector:
    kubernetes.io/os: "linux"
  restartPolicy: "Never"
  serviceAccountName: "default"
  volumes:
  - emptyDir:
      medium: ""
    name: "workspace-volume"
"""
        }
    }
    stages {
        stage('制作镜像') {
            steps {
                container('docker') {
                    sh 'sh scripts/make-docker-image.sh'
                }
            }
        }
    }
}
```

make-docker-image.sh 中的内容如下，这里不能直接放在 Jenkins 中，因为这些变量包含敏感信息，会被渲染出来出现在 Jenkins 的日志里面。

```shell
set -ue -o pipefail
git config --global --add safe.directory /home/jenkins/agent/workspace/go-test
docker login --username=${REGISTRY_USERNAME} --password=${REGISTRY_PASSWORD} ${REGISTRY_ENDPOINT}
docker build \
    --build-arg GIT_USERNAME=$GIT_USERNAME \
    --build-arg GIT_PASSWORD=$GIT_PASSWORD \
    --build-arg REGISTRY_ENDPOINT=$REGISTRY_ENDPOINT \
    --build-arg REGISTRY_NAMESPACE=$REGISTRY_NAMESPACE \
    -t ${REGISTRY_ENDPOINT}/${REGISTRY_NAMESPACE}/go-test:$(git describe --tags) .
docker push ${REGISTRY_ENDPOINT}/${REGISTRY_NAMESPACE}/go-test:$(git describe --tags)
```

秘钥信息通过 k8s 的 secret 传递给 Jenkins

```shell
kubectl get secret ${K8S_SECRET_NAME} -n ${K8S_NAMESPACE} >/dev/null 2>&1 && {
  kubectl create secret generic ${K8S_SECRET_NAME} -n ${K8S_NAMESPACE} \
    --save-config \
    --dry-run=client \
    --from-literal=REGISTRY_ENDPOINT=${REGISTRY_ENDPOINT} \
    --from-literal=REGISTRY_NAMESPACE=${REGISTRY_NAMESPACE} \
    --from-literal=REGISTRY_USERNAME=${REGISTRY_USERNAME} \
    --from-literal=REGISTRY_PASSWORD=${REGISTRY_PASSWORD} \
    --from-literal=GIT_USERNAME=${GIT_USERNAME} \
    --from-literal=GIT_PASSWORD=${GIT_PASSWORD} \
    -o yaml | kubectl apply -f -
} || {
  kubectl create secret generic ${K8S_SECRET_NAME} -n ${K8S_NAMESPACE} \
    --from-literal=REGISTRY_ENDPOINT=${REGISTRY_ENDPOINT} \
    --from-literal=REGISTRY_NAMESPACE=${REGISTRY_NAMESPACE} \
    --from-literal=REGISTRY_USERNAME=${REGISTRY_USERNAME} \
    --from-literal=REGISTRY_PASSWORD=${REGISTRY_PASSWORD} \
    --from-literal=GIT_USERNAME=${GIT_USERNAME} \
    --from-literal=GIT_PASSWORD=${GIT_PASSWORD}
}
```

本来想让 docker 的缓存复用起来，结果 docker 缓存不支持多实例并发访问，此外网络磁盘不如本地 SSD 性能好，解压花了非常多时间

```groovy
pipeline {
    agent {
        kubernetes {
            cloud "kubernetes"
            defaultContainer 'jnlp'
            yaml """
apiVersion: "v1"
kind: "Pod"
spec:
  containers:
  - image: "registry.cn-shanghai.aliyuncs.com/hatlonely/docker:25-rc-git"
    imagePullPolicy: "IfNotPresent"
    name: "docker"
    envFrom:
    - secretRef:
        name: go-test-ci
    resources: {}
    securityContext:
      privileged: true
    tty: false
    volumeMounts:
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
      readOnly: false
    - mountPath: "/var/lib/docker"
      name: "docker-cache"
      readOnly: false
    workingDir: "/home/jenkins/agent"
  hostNetwork: false
  imagePullSecrets:
  - name: "hatlonely-pull-secret"
  nodeSelector:
    kubernetes.io/os: "linux"
  restartPolicy: "Never"
  serviceAccountName: "default"
  volumes:
  - emptyDir:
      medium: ""
    name: "workspace-volume"
  - persistentVolumeClaim:
      claimName: docker-cache
    name: docker-cache
"""
        }
    }
    stages {
        stage('制作镜像') {
            steps {
                container('docker') {
                    sh 'sh scripts/make-docker-image.sh'
                }
            }
        }
    }
}
```

## 参考链接
