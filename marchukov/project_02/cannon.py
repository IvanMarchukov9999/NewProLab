from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from numpy.random import choice
import time
import numpy as np

dcap = dict(DesiredCapabilities.PHANTOMJS)
dcap["phantomjs.page.settings.userAgent"] = ("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 YaBrowser/17.6.1.745 Yowser/2.5 Safari/537.36")
driver = webdriver.Chrome()
driver.set_window_size(1024, 768)

host = "b24-tqj4la.bitrix24.shop"

def user_journey(host):
    driver.get("http://" + host)
    
    steps = np.random.poisson(5)
    print('Steps: %i' % steps)
    
    for i in range(steps):
        print('Turn %i' % i)
        # Переходим в случайный раздел / одел
        el = driver.find_element_by_link_text(np.random.choice(["ОБУВЬ", "ПЛАТЬЯ", "ФУТБОЛКИ"]))
        print(el.text)
        el.click()
        time.sleep(1)
        #time.sleep(np.random.poisson(5)) # случайное время ожидания на странице
        
        # Выбираем случайный товар
        while True:
            items = driver.find_elements_by_class_name('product-item-image-wrapper')
            print(items)
            if len(items) == 0:
                time.sleep(1)
                continue
            np.random.choice(items).click()
            break
        #time.sleep(np.random.poisson(5)) # случайное время ожидания на странице
        
        if np.random.random() < 0.9: # Вероятность 90% что пользователь добавит товар в корзину
            print('Buy')
            # Жмем "Купить"
            driver.find_elements_by_class_name('product-item-detail-buy-button')[0].click()
            #time.sleep(np.random.poisson(5)) # случайное время ожидания на странице
            time.sleep(1)
    
    if np.random.random() < 0.8: # Вероятность 80% что пользователь оформит заказ
        print('Bucket')
        time.sleep(1)
        driver.find_element_by_link_text('Корзина').click()
        # Оформить заказ
        btn = driver.find_elements_by_class_name('basket-checkout-button')
        if len(btn) > 0:
            btn[0].click()
    
while True:
    try:
        user_journey(host)
    except Exception as e:
        print(e)
    finally:
        driver.delete_all_cookies() # Чистим куки, чтобы начать новую сессию