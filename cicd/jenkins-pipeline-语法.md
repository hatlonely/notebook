# jenkins pipeline 语法

pipeline 语法是基于 groovy 语法的 DSL，其语法还是比较简单清晰的。

```groovy
pipeline {
    agent any
    stages {
        stage('基本用法') {
            steps {
                echo 'Hello world!'
                echo env.PATH
                sh 'echo hello world'
            }
        }
        stage('使用 docker') {
            agent {
                docker {
                    image 'node:20.10.0-alpine3.18'
                }
            }
            steps {
                sh 'node --version'
            }
        }
    }
}
```

> 上面这个样例里面会因为宿主机没有安装 docker 而失败。最佳实践是在 k8s 集群中，使用 docker 镜像：

```groovy
pipeline {
    agent {
        kubernetes {
            cloud "kubernetes"
            label "jenkins-jenkins-agent"
            defaultContainer 'jnlp'
        }
    }
    stages {
        stage('使用 docker') {
            steps {
                container('docker') {
                    sh 'docker run hello-world'
                    sh 'ls -al'
                }
            }
        }
    }
}
```

- `cloud` 设置路径 `Manage Jenkins` -> `Clouds` -> `Kubernetes`
- `label` 用来选择用哪个 `Pod Templates`

## 参考链接

- [jenkins pipeline 官网文档](https://www.jenkins.io/doc/book/pipeline/getting-started/)
