# markdown mermaid git graph

## 样例

```mermaid
gitGraph
  commit
  commit
  branch develop
  checkout develop
  commit
  commit
  checkout main
  merge develop
  commit
  commit
```

## git flow 流程图

- 其行为和 git 命令一致，commit 提交代码，branch 创建分支，checkout 切换分支，merge 合并分支
- 改变方向：将 `gitGraph` 声明后面改为 `gitGraph TB` 即可
- 顺序：`order` 属性可以用来固定顺序，其值为权重，数字越大越靠后，比如 `order: 20` 会放到 `order: 12` 后面
- tag: `tag` 属性可以用来标注 tag，比如 `tag: "v1.0.0"` 会在 commit 上显示 `v1.0.0` 标签

```mermaid
gitGraph TB:
  commit tag: "v1.0.0"
  branch develop order: 3
  checkout develop
  branch feature/1 order: 11
  checkout feature/1
  commit
  commit
  checkout develop
  merge feature/1
  branch feature/2 order: 12
  checkout feature/2
  commit
  checkout develop
  branch feature/3 order: 13
  checkout feature/3
  commit
  checkout feature/2
  commit
  checkout develop
  merge feature/3
  checkout feature/2
  commit
  checkout develop
  merge feature/2
  branch release/1.1.0 order: 1
  checkout release/1.1.0
  commit
  checkout develop
  branch feature/4 order: 14
  checkout feature/4
  commit
  checkout release/1.1.0
  commit
  checkout main
  merge release/1.1.0 tag: "v1.1.0"
  checkout develop
  merge release/1.1.0
  checkout feature/4
  commit
  checkout main
  branch hotfix/1.1.1 order: 2
  checkout hotfix/1.1.1
  commit
  checkout main
  merge hotfix/1.1.1 tag: "v1.1.1"
  checkout develop
  merge hotfix/1.1.1
  checkout feature/4
  commit
  checkout develop
  merge feature/4
```

## 参考链接

- [mermaid git graph](https://mermaid.js.org/syntax/gitgraph.html)
