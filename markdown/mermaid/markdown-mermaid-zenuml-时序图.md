# markdown mermaid zenuml 时序图

相比于 sequence 时序图，zenuml 时序图更加简洁，使用更加贴近过程式编程的语法，使用起来更加自然，更具逻辑性，并添加了一些云服务的图标。

## 图标

```mermaid
zenuml
  title 图标
  A
  @Actor B
  @Database C
  @Boundary D
  @Control E
  @Entity F
  @EC2 ec2
  @VPC vpc
  @Lambda lambda
  @RDS rds
```

添加了很多云服务的图标，可以用来画云服务的架构图。

## 代码

```mermaid
zenuml
  A->B.method1() {
    B.method2()
    B->C.method3() {
        return result3
    }
    return result1    
  }
  
  while (times_100) {
    A->C.method4() {
      return result4
    }
  }
  
  if (cond1) {
    A->B.method5() {
      return result5
    }
  } else if (cond2) {
    A->C.method6() {
      return result6
    }
  }
  
  par {
    A->B.method7() {
      return result7
    }
    A->C.method8() {
      return result8
    }
  }
  
  try {
    A->B.method9() {
      return result9
    }
  } catch (Exception e) {
    A->C.method10() {
      return result10
    }
  }
```

## 参考链接

- [mermaid zenuml](https://mermaid.js.org/syntax/zenuml.html)
