import time

import selenium.webdriver
import selenium.webdriver.chrome.service
import selenium.webdriver.common.by
import webdriver_manager.chrome

service = selenium.webdriver.chrome.service.Service(webdriver_manager.chrome.ChromeDriverManager().install())
service.start()

options = selenium.webdriver.ChromeOptions()
driver = selenium.webdriver.Chrome(service=service, options=options)
driver.get("https://www.baidu.com")

search_input = driver.find_element(by=selenium.webdriver.common.by.By.ID, value="kw")
search_input.send_keys("selenium")
search_input.submit()

time.sleep(10)
