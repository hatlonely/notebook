# svelte 快速入门

1. 安装 node

```shell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.zshrc
nvm install v18.18.0
```

2. 创建 svelte 项目

```shell
npx degit sveltejs/template helloworld
cd helloworld

npm install
npm run dev
```

使用 typescript

```shell
npx degit sveltejs/template helloworld
cd helloworld

node scripts/setupTypeScript.js
npm install --save-dev @tsconfig/svelte typescript svelte-preprocess svelte-check
npm run dev
```

## 参考链接

- [svelte 官网入门教程](https://www.svelte.cn/blog/the-easiest-way-to-get-started)
- [ubuntu 22 安装 node 18](https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-22-04)
