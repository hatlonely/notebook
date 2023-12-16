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

## 参考链接

- [flowbite svelte](https://flowbite-svelte.com/docs/pages/quickstart)
- [svelte kit static adapter](https://kit.svelte.dev/docs/adapter-static)
