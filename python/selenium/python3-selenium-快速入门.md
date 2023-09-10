# python3 selenium 快速入门

## 安装

```bash
pip install selenium
```

安装 google chrome

```
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y xdg-utils
sudo dpkg -i google-chrome-stable_current_amd64.deb
```

## 快速入门

```python
import pathlib
import time

import selenium.webdriver
import selenium.webdriver.chrome.service
import selenium.webdriver.common.action_chains
import selenium.webdriver.common.by
import webdriver_manager.chrome


def start_chrome_service() -> (selenium.webdriver.Chrome, selenium.webdriver.common.action_chains.ActionChains):
    service = selenium.webdriver.chrome.service.Service(webdriver_manager.chrome.ChromeDriverManager().install())
    service.start()

    options = selenium.webdriver.ChromeOptions()
    options.add_argument("--no-sandbox")
    options.add_argument(f"--user-data-dir={pathlib.Path.home()}/chrome")
    driver = selenium.webdriver.Chrome(service=service, options=options)
    action_chain = selenium.webdriver.common.action_chains.ActionChains(driver)

    return driver, action_chain


def quick_start(driver, action_chain):
    _ = action_chain
    driver.get("https://www.baidu.com")
    search_input = driver.find_element(by=selenium.webdriver.common.by.By.ID, value="kw")
    search_input.send_keys("selenium")
    search_input.submit()
    time.sleep(20)


def main():
    driver, action_chain = start_chrome_service()
    quick_start(driver, action_chain)


if __name__ == "__main__":
    main()
```

## 参考链接

- [Selenium Python Tutorial (with Example)](https://www.browserstack.com/guide/python-selenium-to-run-web-automation-test)
- [selenium chrome driver](https://sites.google.com/chromium.org/driver/?pli=1)
- [selenium chrome driver download](https://sites.google.com/chromium.org/driver/downloads)
- [chrome 浏览器用户 profile 目录](https://sessionbuddy.com/chrome-profile-location/)
- [How to use a specific Chrome profile in Python Selenium](https://www.educative.io/answers/how-to-use-a-specific-chrome-profile-in-python-selenium)
