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

## 参考链接

- [jenkins pipeline 官网文档](https://www.jenkins.io/doc/book/pipeline/getting-started/)
