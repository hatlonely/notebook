# 从豆瓣上下载王姿允的照片
# https://www.douban.com/personage/27549915/photos/

import time
import json
import os
import random
import hashlib

from playwright.sync_api import Playwright, sync_playwright, expect


def md5(input_string):
    m = hashlib.md5()
    m.update(input_string.encode("utf-8"))
    md5_hash = m.hexdigest()
    return md5_hash


def dump_cookies(context, cookies_file):
    with open(cookies_file, "w") as f:
        f.write(json.dumps(context.cookies()))


def load_cookies(context, cookies_file):
    if not os.path.exists(cookies_file):
        return
    with open(cookies_file, "r") as f:
        cookies = json.loads(f.read())
        context.add_cookies(cookies)


output_dir = "output"


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


def run(playwright: Playwright) -> None:
    cookie_file = f"{os.path.expanduser('~')}/playwright/cookies/douban.com.json"
    browser = playwright.chromium.launch(headless=False)
    context = browser.new_context()

    load_cookies(context, cookie_file)

    page = context.new_page()
    page.goto("https://www.douban.com/personage/27549915/photos/")

    traveled = set()

    while True:
        photo_list_ele = page.locator("#content > div > div.article > ul")
        # 给当前页面签名，判断页面是否已经访问过，如果访问过直接退出
        sign = md5(photo_list_ele.inner_html())
        if sign in traveled:
            break
        traveled.add(sign)

        # 逐张图片点击
        for ele in photo_list_ele.locator("li").all():
            try:
                ele.scroll_into_view_if_needed()
                # 点击图片
                with page.expect_popup() as page_detail_info:
                    ele.click()
                page_detail = page_detail_info.value
                time.sleep(1)

                photo_origin_link = (
                    page_detail.locator("span")
                    .filter(has_text="查看原图")
                    .get_by_role("link")
                    .get_attribute("href")
                )

                print(photo_origin_link)

                # 查看原图
                with page_detail.expect_popup() as page_origin_photo_info1:
                    page_detail.locator("span").filter(has_text="查看原图").get_by_role(
                        "link"
                    ).click()
                page_origin_photo1 = page_origin_photo_info1.value
                time.sleep(random.uniform(0.37, 2.43))

                # 在新的页面下载图片
                page_origin_photo2 = context.new_page()
                time.sleep(random.uniform(0.27, 1.43))
                page_origin_photo2.on("response", download_photo)
                page_origin_photo2.goto(photo_origin_link)

                time.sleep(random.uniform(0.44, 4.46))

                page_origin_photo1.close()
                page_origin_photo2.close()
                page_detail.close()

                time.sleep(random.uniform(0.88, 1.96))
            except Exception as e:
                print(e)

        # 失败重试三次
        count = 0
        while True:
            try:
                # 翻页
                next_page_label = page.get_by_role("link", name="后页>")
                next_page_label.scroll_into_view_if_needed(timeout=10000)
                next_page_label.click()
                time.sleep(random.uniform(0.88, 5.96))
                break
            except Exception as e:
                print(e)
                count += 1
                time.sleep(random.uniform(0.88, 5.96))
                if count > 3:
                    break

    dump_cookies(context, cookie_file)

    context.close()
    browser.close()


with sync_playwright() as playwright:
    run(playwright)
