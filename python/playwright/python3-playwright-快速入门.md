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

## 参考链接

- [项目地址](https://github.com/microsoft/playwright)
- [playwright python 开发文档](https://playwright.dev/python/docs/intro)
