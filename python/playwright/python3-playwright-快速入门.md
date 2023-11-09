# python3 playwright 快速入门

## 安装

```shell
pip install playwright

playwright install
```

## 快速入门

生成代码

```shell
playwright codegen https://www.baidu.com
```

搜索百度后能自动生成如下代码

```python
import time

from playwright.sync_api import Playwright, sync_playwright


def run(playwright: Playwright) -> None:
    browser = playwright.chromium.launch(headless=False)
    context = browser.new_context()
    page = context.new_page()
    page.goto("https://www.baidu.com/")
    page.locator("#kw").click()
    page.locator("#kw").fill("playwright")
    page.get_by_role("button", name="百度一下").click()

    time.sleep(100)
    # ---------------------
    context.close()
    browser.close()


with sync_playwright() as playwright:
    run(playwright)
```

## 常用选择器

- `locator`: css 选择器
- `get_by_role`: role 选择器
- `get_by_text`: 文本选择器
- `get_by_title`: title 选择器

> `element.scroll_into_view_if_needed()` 可以自动滚动到可视区域

## 获取页面网络资源

通过 `page.on("request", callback)` 和 `page.on("response", callback)` 可以获取页面的网络请求和响应

```python
page.on("request", lambda request: print(">>", request.method, request.url))
page.on("response", lambda response: print("<<", response.status, response.url))
```

用这个机制可以实现图片下载功能

```python
def download_photo(res):
    print(res.ok)
    print(res.request.resource_type)
    if not res.ok:
        return
    filename = os.path.basename(res.url)[-100:]
    print(filename)
    f = open(f"{output_dir}/{filename}", "wb")
    f.write(res.body())
    f.close()

page.on("response", download_photo)
```

## cookie 信息保存

可以从 context 中获取 cookie 和保存 cookie

```python
def dump_cookies(context, cookies_file):
    with open(cookies_file, "w") as f:
        f.write(json.dumps(context.cookies()))


def load_cookies(context, cookies_file):
    if not os.path.exists(cookies_file):
        return
    with open(cookies_file, "r") as f:
        cookies = json.loads(f.read())
        context.add_cookies(cookies)

def run(playwright: Playwright) -> None:
    cookie_file = f"{os.path.expanduser('~')}/playwright/cookies/www.example.com.json"
    browser = playwright.chromium.launch(headless=False)
    context = browser.new_context()
    load_cookies(context, cookie_file)
    page = context.new_page()
    page.goto("https://www.example.com")

    dump_cookies(context, cookie_file)

    context.close()
    browser.close()
```

## 参考链接

- [项目地址](https://github.com/microsoft/playwright)
- [playwright python 开发文档](https://playwright.dev/python/docs/intro)
