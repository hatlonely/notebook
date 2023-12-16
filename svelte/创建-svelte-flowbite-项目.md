# 创建 svelte flowbite 项目

1. 安装 sveltekit

```shell
npm create svelte@latest my-app
cd my-app
npm install
```

2. 使用 tailwind css

```shell
npx svelte-add@latest tailwindcss
npm install
```

3. 使用 flowbite

```shell
npm i -D flowbite-svelte flowbite
```

4. 配置 tailwind.config.cjs

```js
const config = {
  content: [
    "./src/**/*.{html,js,svelte,ts}",
    "./node_modules/flowbite-svelte/**/*.{html,js,svelte,ts}",
  ],

  plugins: [require("flowbite/plugin")],

  darkMode: "class",

  theme: {
    extend: {
      colors: {
        // flowbite-svelte
        primary: {
          50: "#FFF5F2",
          100: "#FFF1EE",
          200: "#FFE4DE",
          300: "#FFD5CC",
          400: "#FFBCAD",
          500: "#FE795D",
          600: "#EF562F",
          700: "#EB4F27",
          800: "#CC4522",
          900: "#A5371B",
        },
      },
    },
  },
};

module.exports = config;
```

5. 使用静态路由

```shell
npm i -D @sveltejs/adapter-static
npm i -D @sveltejs/adapter-static@2.0.3
```

修改 `svelte.config.js`

```js
import adapter from "@sveltejs/adapter-static";

export default {
  kit: {
    adapter: adapter({
      // default options are shown. On some platforms
      // these options are set automatically — see below
      pages: "build",
      assets: "build",
      fallback: undefined,
      precompress: false,
      strict: true,
    }),
  },
};
```

添加 src/routes/+layout.js

```
export const prerender = true;
```

## 常见错误

`npm run build` 报错，是因为 `@sveltejs/adapter-static` 版本过高，降低版本到 `^2.0.3` 即可

```
> Using @sveltejs/adapter-static
error during build:
TypeError: builder.generateEnvModule is not a function
    at adapt (file:///home/hatlonely/gitee.com/hatlonely/devops-console/node_modules/.store/@sveltejs+adapter-static@3.0.0/node_modules/@sveltejs/adapter-static/index.js:65:12)
    at adapt (file:///home/hatlonely/gitee.com/hatlonely/devops-console/node_modules/.store/@sveltejs+kit@1.30.3/node_modules/@sveltejs/kit/src/core/adapt/index.js:37:8)
    at finalise (file:///home/hatlonely/gitee.com/hatlonely/devops-console/node_modules/.store/@sveltejs+kit@1.30.3/node_modules/@sveltejs/kit/src/exports/vite/index.js:810:13)
    at async Object.handler (file:///home/hatlonely/gitee.com/hatlonely/devops-console/node_modules/.store/@sveltejs+kit@1.30.3/node_modules/@sveltejs/kit/src/exports/vite/index.js:840:5)
    at async PluginDriver.hookParallel (file:///home/hatlonely/gitee.com/hatlonely/devops-console/node_modules/.store/rollup@3.29.4/node_modules/rollup/dist/es/shared/node-entry.js:25466:17)
    at async Object.close (file:///home/hatlonely/gitee.com/hatlonely/devops-console/node_modules/.store/rollup@3.29.4/node_modules/rollup/dist/es/shared/node-entry.js:26726:13)
    at async build (file:///home/hatlonely/gitee.com/hatlonely/devops-console/node_modules/.store/vite@4.5.1/node_modules/vite/dist/node/chunks/dep-68d1a114.js:48095:13)
    at async CAC.<anonymous> (file:///home/hatlonely/gitee.com/hatlonely/devops-console/node_modules/.store/vite@4.5.1/node_modules/vite/dist/node/cli.js:842:9)
```

## 参考链接

- [flowbite svelte](https://flowbite-svelte.com/docs/pages/quickstart)
- [svelte kit static adapter](https://kit.svelte.dev/docs/adapter-static)
