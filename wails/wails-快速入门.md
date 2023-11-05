# wails 快速入门

## 安装

```shell
go install github.com/wailsapp/wails/v2/cmd/wails@latest
sudo apt install -y libgtk-3-dev
sudo apt install -y libwebkit2gtk-4.0-dev
sudo apt install -y nsis
```

## 创建项目

```shell
wails init -n helloworld -t svelte-ts
```

## 创建 svelte 项目

```shell
wails init -n helloworld -t svelte-ts

mv helloworld/* .
mv helloworld/.gitignore .
rmdir helloworld

sed -i 's|"auto",|"auto",\n  "wailsjsdir": "./frontend/src/lib",|' wails.json
sed -i "s|all:frontend/dist|all:frontend/build|" main.go

rm -rf frontend
npm create svelte@latest frontend
npm i -D @skeletonlabs/skeleton @skeletonlabs/tw-plugin
npm add -D @types/node
cd frontend
npm uninstall @sveltejs/adapter-auto
npm i -D @sveltejs/adapter-static
echo -e "export const prerender = true\nexport const ssr = false" > src/routes/+layout.ts
sed -i "s|-auto';|-static';|" svelte.config.js
cd ..
```

修改 wails.json

## 参考链接

- [wails 安装](https://wails.io/docs/gettingstarted/installation/)
- [wails 支持 svelte kit](https://wails.io/docs/guides/sveltekit/)
