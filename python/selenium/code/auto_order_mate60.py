#!/usr/bin/env python3
import datetime
import os
import pathlib
import time

import selenium.webdriver
import selenium.webdriver.chrome.service
import selenium.webdriver.common.action_chains
import selenium.webdriver.common.by
import selenium.webdriver.remote.webdriver
import selenium.webdriver.support.expected_conditions
import selenium.webdriver.support.ui
import webdriver_manager.chrome

username = os.getenv('HUAWEI_MALL_USERNAME')
password = os.getenv('HUAWEI_MALL_PASSWORD')

order_time = datetime.datetime.strptime("2023-09-11 10:08:00", "%Y-%m-%d %H:%M:%S")
print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(time.time())))


def start_chrome_service() -> (selenium.webdriver.Chrome, selenium.webdriver.common.action_chains.ActionChains):
    service = selenium.webdriver.chrome.service.Service(webdriver_manager.chrome.ChromeDriverManager().install())
    service.start()

    options = selenium.webdriver.ChromeOptions()
    options.add_argument("--no-sandbox")
    options.add_argument(f"--user-data-dir={pathlib.Path.home()}/chrome")
    driver = selenium.webdriver.Chrome(service=service, options=options)
    action_chain = selenium.webdriver.common.action_chains.ActionChains(driver)

    return driver, action_chain


def find_element_by_xpath(driver: selenium.webdriver.Chrome, xpath) -> selenium.webdriver.remote.webdriver.WebElement:
    try:
        return driver.find_element(by=selenium.webdriver.common.by.By.XPATH, value=xpath)
    except Exception as e:
        _ = e


def wait_element_by_xpath(driver: selenium.webdriver.Chrome, xpath) -> selenium.webdriver.remote.webdriver.WebElement:
    try:
        return selenium.webdriver.support.ui.WebDriverWait(driver, 20).until(
            selenium.webdriver.support.expected_conditions.presence_of_element_located((
                selenium.webdriver.common.by.By.XPATH,
                xpath
            ))
        )
    except Exception as e:
        _ = e


# 登录
def login(driver):
    driver.get("https://www.vmall.com/index.html")
    time.sleep(1)
    print("跳转到登录页面")
    wait_element_by_xpath(
        driver,
        '//*[@id="home_no_focus_outline"]/div[3]/div[5]/div/div/div[2]/div[1]/div/div'
    ).click()
    time.sleep(2)
    print("输入用户名")
    wait_element_by_xpath(
        driver,
        '/html/body/div/div/div[1]/div[3]/div[3]/span[3]/div[1]/form/div[2]/div/div/div/input[@placeholder="手机号/邮件地址/帐号名"]'
    ).send_keys(username)
    time.sleep(0.3)
    print("输入密码")
    wait_element_by_xpath(
        driver,
        '/html/body/div/div/div[1]/div[3]/div[3]/span[3]/div[1]/form/div[3]/div/div/div/input[@placeholder="密码"]'
    ).send_keys(password)
    time.sleep(0.4)
    print("点击登录")
    wait_element_by_xpath(
        driver, '/html/body/div/div/div[1]/div[3]/div[3]/span[3]/div[1]/div[2]/div/div/div'
    ).click()
    time.sleep(0.3)
    print("登录成功！！！！!")


# 下单
def order_mate60(driver):
    driver.get("https://www.vmall.com/product/10086764961298.html")
    current_uri = driver.current_url

    print(datetime.datetime.now(), "等待抢单")
    time.sleep((order_time - datetime.datetime.now()).total_seconds())
    print(datetime.datetime.now(), "开始抢单")

    for i in range(10):
        print("刷新页面")
        driver.refresh()

        print("选择宣白")
        wait_element_by_xpath(driver, '//*[@id="pro-skus"]/dl/div/ul/li/div/a[@title="宣白"]').click()
        print("选择16GB+512GB")
        wait_element_by_xpath(driver, '//*[@id="pro-skus"]/dl/div/ul/li/div/a[@title="16GB+512GB"]').click()

        try:
            find_element_by_xpath(driver, '//*[@id="pro-operation"]/a').click()
        except Exception as e:
            print("未找到下单按钮", e)
        time.sleep(0.1)
        if driver.current_url != current_uri:
            print("成功下单！！！！！")
            break
        else:
            print("下单未生效")

        time.sleep(20)


# 确认
def confirm_order(driver):
    try:
        wait_element_by_xpath(driver, '//*[@id="checkoutSubmit"]/span').click()
        print("已点击确认订单！！！！！")
    except Exception as e:
        print('未找到确认订单按钮', e)


def main():
    driver, action_chain = start_chrome_service()
    try:
        login(driver)
        order_mate60(driver)
        confirm_order(driver)
    except Exception as e:
        print(e)
    time.sleep(10000)


if __name__ == "__main__":
    main()
