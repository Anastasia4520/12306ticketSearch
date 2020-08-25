# -*-coding:utf-8-*-
"""命令火车票查看器
Usage:
    ticket.py [-g,-d,-t,-k,-z] <from> <to> <date>
    ticket.py (-h|--help)
Options:
    -g  高铁
    -d  动车
    -t  特快
    -k  快速
    -z  直达
"""
from selenium import webdriver
from lxml import etree
from prettytable import PrettyTable
from colorama import init,Fore
from docopt import docopt

def open_browser(url):
    browser = webdriver.Chrome(r'C:\Users\ling li\AppData\Local\Google\Chrome\Application\chromedriver.exe')
    return browser

def date_transform(date):
    year,month,day = date.split("-")
    monthes = {
        '01':'一月',
        '02':'二月',
        '03':'三月',
        '04':'四月',
        '05':'五月',
        '06':'六月',
        '07':'七月',
        '08':'八月',
        '09':'九月',
        '10':'十月',
        '11':'十一月',
        '12':'十二月'
    }
    days = {
        '01':'1',
        '02':'2',
        '03':'3',
        '04':'4',
        '05':'5',
        '06':'6',
        '07':'7',
        '08':'8',
        '09':'9'
    }
    month = monthes[month]
    if day in days:
        day = days[day]

    return year,month,day
def input_information(main_url,from_station,to_station,date,arguements):
    # 打开浏览器
    global browser
    browser = open_browser(main_url)
    browser.get(main_url)
    browser.find_element_by_id("fromStationText").click()
    browser.find_element_by_xpath('//li[@title="%s"]'%from_station).click()

    browser.find_element_by_id("toStationText").click()
    browser.find_element_by_xpath('//li[@title="%s"]'%to_station).click()

    year,month,day = date_transform(date)
    browser.find_element_by_id("train_date").click()
    browser.find_element_by_xpath('//div[@class="year"]//input[@type="text"]').click()
    browser.find_element_by_xpath('//li[text()="%s"]'%year).click()
    browser.find_element_by_xpath('//div[@class="month"]//input[@type="text"]').click()
    browser.find_element_by_xpath('//li[text()="%s"]'%month).click()
    browser.find_elements_by_xpath('//div[text()=%d]'%int(day))[0].click()

    browser.find_elements_by_id("search_one")[0].click()
    browser.switch_to.window(browser.window_handles[-1])
    if arguements['-g'] is True:
        print(browser.find_elements_by_xpath('//li//input[@value="G"]'))
        browser.find_elements_by_xpath('//li//input[@value="G"]')[0].click()
    if arguements['-d'] is True:
        browser.find_elements_by_xpath('//li//input[@value="D"]')[0].click()
    if arguements['-z'] is True:
        browser.find_elements_by_xpath('//li//input[@value="Z"]')[0].click()
    if arguements['-t'] is True:
        browser.find_elements_by_xpath('//li//input[@value="T"]')[0].click()
    if arguements['-k'] is True:
        browser.find_elements_by_xpath('//li//input[@value="K"]')[0].click()
    result = browser.page_source
    return result

def extract_information(result):
    html = etree.HTML(result)
    stations = html.xpath('//a[@title="点击查看停靠站信息"]//text()')
    information = html.xpath('//div[@class="ticket-info clearfix"]//text()')

    id = html.xpath('//tr/@id')
    id.remove('float')
    i = 0
    ticket_id = []
    for each in id:
        i += 1
        if i%2!=0:
            ticket_id.append(each)
    informations= []
    for each in ticket_id:
        information = html.xpath('//tr[@id="%s"]//text()'%each)
        for j in information:
            if j == ' ':
                information.remove(' ')
        information.remove('查看票价')
        information.remove('预订')
        a = '\n'.join([Fore.GREEN+information[1]+Fore.RESET,Fore.RED+information[2]+Fore.RESET])
        b = '\n'.join([Fore.GREEN+information[3]+Fore.RESET,Fore.RED+information[4]+Fore.RESET])
        c = '\n'.join([information[5],information[6]])

        new = [information[0],a,b,c]+information[7:]
        informations.append(new)
    return informations

def print_information(information):
    header = '车次 车站 时间 历时 商务座 一等座 二等座 高级软卧 软卧 动卧 硬卧 软座 硬座 无座 其他'.split(" ")
    tab = PrettyTable(header)
    tab.padding_width = 1
    for each in information:
        print(each)
        tab.add_row(each)
    print(tab)

def main():
    init()
    arguements = docopt(__doc__)
    from_station = arguements["<from>"]
    to_station = arguements["<to>"]
    date = arguements["<date>"]
    main_url = "https://www.12306.cn/index/"
    # 获取车站信息的网页信息
    result = input_information(main_url,from_station,to_station,date,arguements)
    # 提取车站信息
    information = extract_information(result)
    print_information(information)



    browser.quit()




if __name__ == '__main__':
    main()

































