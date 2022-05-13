---
draft: true
title: "Scrapy使用案例——房天下"
subtitle: "Scrapy2.6"
date: 2022-04-09T10:40:45+08:00
lastmod: 2022-04-09T10:40:45+08:00
authors: []
description: "爬虫应该是python使用者比较重要的一门技能，学会这个也能进厂了，本项目婴儿级别，实现不了你打我。"

tags: [Scrapy2.6]
categories: [tutorial]

---

参考：

+ https://www.bilibili.com/video/BV1jx411b7E3?p=1

## Scrapy框架overview

使用了Twisted异步网络框架来处理网络通讯，可以加快我们的下载速度，不用自己去实现异步框架，并且包含了各种中间件接口，可以灵活完成各种需求。



### Scrapy结构组成

| Components             | Introduction                                                 |
| ---------------------- | ------------------------------------------------------------ |
| Scrapy Engine          | Scrapy引擎负责控制各组件之间的所有数据流，并在特定动作发生时触发事件。 |
| Scheduler              | 调度器接收来自引擎的请求并将它们按一定要求排入队列以便后续响应引擎。（爬虫执行过程需要时间，不能同时完成所有任务，因而需要任务队列。） |
| Downloader             | 下载器负责抓取网页并将它们喂给引擎，引擎转而喂给Spider爬虫程序。 |
| Spider                 | 爬虫是由Scrapy用户自行编写的客制化类，用来解析响应以及提取网页数据项或其他请求。 |
| Item Pipline           | 负责处理由爬虫提取的items。典型任务包括清理数据，验证数据以及持续化存储在数据库中等。 |
| Downloader middlewares | 下载中间件是位于引擎和下载器之间的特定钩子程序（可以理解为连接点），用来处理由引擎发往下载器的请求已经来自下载器发回引擎的响应。使用下载中间件的情景如下：<br/>- 在请求发送给下载器之前进行处理（比如就在Scrapy向网页发送请求时）<br/>- 在响应发往爬虫程序时，改写得到的响应。<br/>- 发送一个新的请求而不是将得到的响应发给爬虫程序。<br/>- 在不抓取网页的情况下向爬虫传递一个响应。<br/>- 静默丢弃一些请求。 |
| Spider middlewares     | 爬虫程序中间件是位于引擎和爬虫程序之间的特定的钩子程序，它能够处理爬虫程序的输入（发往爬虫程序的响应）以及爬虫程序得到的输出（数据项和请求）。使用爬虫程序中间件的情景如下：<br/>- 后处理爬虫程序回调的输出 - 更改/添加/删除请求或item；<br/>- 后处理启动请求；<br/>- 处理爬虫程序异常；<br/>- 对于一些基于响应内容的请求，调用errback而不是callback。 |

### Scrapy工作数据流

> 简略框架

![scrapy_architecture_01](MD_img/scrapy_architecture_01.png)

> 详细框架

![scrapy_architecture_02](MD_img/scrapy_architecture_02.png)

**Scrapy 的数据流由执行引擎进行控制，进行过程如下（步骤序号对应上图）**：

1. **流程开始**，引擎从爬虫程序得到初始的爬取请求。
2. 引擎将Requests放入调度器并请求进行下一个爬取的Requests。
3. 调度器返回下一个Requests给引擎。
4. 引擎将得到的Requests发送给下载器，途径下载器中间件。
5. 在网页完成下载的同时，生成页面的响应并将它发送给引擎，途径下载器中间件。
6. 引擎收到来自下载器的响应并将其发送给爬虫程序处理，途径爬虫程序中间件。
7. 爬虫程序处理得到的响应并将抓取的items和新的Requests返回给引擎，途径爬虫中间件。
8. 引擎发送处理好的items发送给Item Piplines，并将发送处理好的Requests给调度器并请求下一个爬取的Requests。
9. 重复步骤3直到调度器里没有更多的Requests，**流程结束**。



## Scrapy 安装

### 文档

官方文档：https://docs.scrapy.org/en/latest

中文维护：http://scrapy-chs.readthedocs.io/zh_CN/latest/index.html

### 环境介绍

 Ubuntu 21.10,	Python3.10.3，pyenv

### 安装流程

pip 更新

```bash
python -m pip install --upgrade pip
```

安装scrapy

```ba
pip install scrapy
```

## Scrapy基本使用

本次实践的是房天下网站，仅用于学习交流，不作任何商业用途，比如就以二手房为例。

```flow
st=>start: 开始
op1=>operation: 进入城市列表页，获取每个城市房源的进入链接
op2=>operation: 进入每个城市对应的房源页面。
e=>end
st->op1->op2->e

```



### 创建scrapy项目

```bash
cd ~
scrapy startproject scrapy_fang
```

### 创建爬虫，注意爬虫名字不要和项目域名相同

```bash
cd scrapy_fang
scrapy genspider esf esf.fang.com
```

### 基本使用

命令行输入scrapy进行查看

```bash
scrapy
```

>
> Scrapy 2.6.1 - project: scrapy_fang
>
> Usage:
>   scrapy <command> [options] [args]
>
> Available commands:
>   bench         Run quick benchmark test
>   check         Check spider contracts
>   commands      
>   crawl         Run a spider
>   edit          Edit spider
>   fetch         Fetch a URL using the Scrapy downloader
>   genspider     Generate new spider using pre-defined templates
>   list          List available spiders
>   parse         Parse URL (using its spider) and print the results
>   runspider     Run a self-contained spider (without creating a project)
>   settings      Get settings values
>   shell         Interactive scraping console
>   startproject  Create new project
>   version       Print Scrapy version
>   view          Open URL in browser, as seen by Scrapy
>
> Use "scrapy <command> -h" to see more info about a command

### 模拟浏览器访问

设置请求头(模拟浏览器访问)，在settings.py下添加，可以更换，随便打开一个网页，F12查看network，然后找一下User-Agent内容。

```python
USER_AGENT  = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36'
```

或者在下载器中间件写入如下类，随机请求头

```python
class UserAgentDownloadMiddleware(object):
    def __int__(self):
        self.User_Agents = [
            'Mozilla/5.0 (X11; Linux i686; rv:64.0) Gecko/20100101 Firefox/64.0',
            'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.13; ko; rv:1.9.1b2) Gecko/2008'
            '1201 Firefox/60.0',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)'
            ' Chrome/70.0.3538.77 Safari/537.36',
            'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML like Gecko) Chrome'
            '/44.0.2403.155 Safari/537.36',
        ]

    def process_request(self, request, spider):
        USER_AGENT = random.choice(self.User_Agents)
        request.headers['User-Agent'] = USER_AGENT
```

**==不要忘记==**在settings.py里头指定该类为下载器中间件，否则无效，数字543等指定优先级，越小优先级越高。

```python
DOWNLOADER_MIDDLEWARES = {
   'scrapy_fang.middlewares.UserAgentDownloadMiddleware': 543,
}
```

### 请求和下载设定

在settings.py中写入如下

```
# 限制并发Requests数量，默认是16
CONCURRENT_REQUESTS = 32
# 延时最低为2s
DOWNLOAD_DELAY = 1 
# 启动[自动限速]
AUTOTHROTTLE_ENABLED = True
# 开启[自动限速]的debug
AUTOTHROTTLE_DEBUG = True
# 设置最大下载延时
AUTOTHROTTLE_MAX_DELAY = 10 
# 设置下载超时
DOWNLOAD_TIMEOUT = 15
# 限制对该网站的并发请求数
CONCURRENT_REQUESTS_PER_DOMAIN = 4 
```

## 二手房链接获取爬虫

### 进入链接入口页面

https://www.fang.com/SoufunFamily.htm  ，测试插件是xpath helper

![image-20220504152225594](MD_img/image-20220504152225594.png)

正确定位到各城市入口页面

```xpath
//*[@id='senfe']//tr
```

测试程序里的xpath路径是否能抓到东西。

```bash
scrapy shell http://www.fang.com/SoufunFamily.htm
```

> [s] Available Scrapy objects:
> 		[s]   scrapy     scrapy module (contains scrapy.Request, scrapy.Selector, etc)
> 		[s]   crawler    <scrapy.crawler.Crawler object at 0x7f34bb89eaa0>
> 		[s]   item       {}
> 		[s]   request    <GET http://www.fang.com/SoufunFamily.htm>
> 		[s]   response   <200 https://www.fang.com/SoufunFamily.htm>
> 		[s]   settings   <scrapy.settings.Settings object at 0x7f34bb89f3a0>
> 		[s]   spider     <DefaultSpider 'default' at 0x7f34bb2bc760>
> 		[s] Useful shortcuts:
> 		[s]   fetch(url[, redirect=True]) Fetch URL and update local objects (by default, redirects are followed)
> 		[s]   fetch(req)                  Fetch a scrapy.Request and update local objects 
> 		[s]   shelp()           Shell help (print this help)
> 		[s]   view(response)    View response in a browser

```bash
>>>response.xpath("//*[@id='senfe']//tr")
```

> [<Selector xpath="//*[@id='senfe']//tr" data='<tr id="sffamily_B03_01">\r\n\t\t\t\t<td va...'>, <Selector xpath="//*[@id='senfe']//tr" data='<tr id="sffamily_B03_02">\r\n\t\t\t\t<td wi...'>, <Selector xpath="//*[@id='senfe']//tr" data='<tr id="sffamily_B03_02">\r\n\t\t\t\t<td va...'>, ……

**抓取成功，想要抓取html里的其他内容也可以进行类似的操作，此处不一一列举。**

注意xpath返回的是xpath对象组成的列表，而不是单纯的网页源码文本，要想获得内容需要.extrract()

```
>>>response.xpath("//*[@id='senfe']//tr").extract()
```

> ['<tr id="sffamily_B03_01">\r\n\t\t\t\t<td valign="top" class="font01" style="text-align:center;">\xa0</td>\r\n\t\t\t\t<td valign="top"><strong>直辖市</strong></td>\r\n\t\t\t\t<td>\r\n\t\t\t\t\t<a href="http://bj.fang.com/" target="ank" class="red">北京</a> \r\n\t\t\t\t\t<a href="http://sh.fang.com/" target="_blank" class="red">上海</a> \r\n\t\t\t<a href="http://tj.fang.com/" target="_blank" class="red">天津</a> \r\n\t\t\t\t\t<a href="http://cq.fang.com/" targ="_blank" class="red">重庆</a>\r\n\t\t\t\t</td>\r\n\t\t\t</tr>',……

这样就得到了抓取的网页html源码，每个tr标签是一个列表项~

### 编写`items.py`

#### 抓取城市入口链接数据类

现在，明确我们要从这个页面获得什么数据，显然，我们需要获取，省份，城市，以及该城市二手房页面进入的链接，所以我们需要编写item类，用来暂时存放我们每个元数据的数据字典，scrapy给我们定义好了一个Item类，可以用来创建类字典的数据类型，可以当字典用，后续看。

```
class UrlItem(scrapy.Item):
    # 省份
    province = scrapy.Field()
    # 城市
    city = scrapy.Field()
    # 二手房链接
    esfhouse_url = scrapy.Field()
```

### 建立并编写spiders目录下的`esf.py`

主要属性和方法

+ name

  > 定义sipder名字的字符串，必须。
  >
  > 例如，如果spider爬取qq.com，该spider的name通常定义为qq

+ allowed_domains

  > 包含了spider允许爬取的域名列表，可选。

+ start_urls

  > 初始URL列表。当没有制定特定的URL时，spider将从该列表中进行爬取，必选。

+ start_requests(self)

  > 该方法必须返回一个可迭代（iterable）对象。该对象包含了spider用于爬取（默认实现是使用start_urls的url）的第一个Request。
  >
  > 当spider启动爬取并且未指定start_urls，该方法将被调用。

+ parse(self, response)

  > 当请求url返回网页没有指定回调函数时，默认的Requests对象回调函数是parse。用来处理网页返回的response，以及生成item和Requests对象。

+ log(self, message[, level, component])

  > 使用scrapy.log.msg()方法记录(log)message。

```python
class EsfSpider(scrapy.Spider):
    # 别名，后续用来其启动爬虫
    name = 'esf'
    # 允许爬取的页面
    allowed_domains = ['fang.com']
    # 启动爬取的页面
    start_urls = ['http://www.fang.com/SoufunFamily.htm']

    # Scrapy框架默认调用这个方法。response.body是html源码
    def parse(self, response):
        item = UrlItem()
        # 获取数据的每一行tr，可能一行爲一個省份，也可能多行爲一個省份
        trs = response.xpath("//*[@id='senfe']//tr")

        # print(trs)
        city_lis = []
        for tr in trs:
            # 获取省份的td
            tds = tr.xpath(".//td[not(@class)]")  # "not(@class)" ：没有为class赋值的被选取
            province_td = tds[0]
            # #获取省份的值
            province_text = province_td.xpath(".//text()").get()
            # #给省份去掉 多余空格
            province_text = re.sub(r'\s', '', province_text)
            # 判断省份是否为空的
            if province_text:
                # 将不为空的省份赋值给province
                province = province_text
                # 除去国外的链接
                if province == '其它':
                    break
                # 除去直辖市中的重庆和天津，因为在文中有写到
                if province == '重庆' or province == '天津':
                    continue
                item['province'] = province

            # 获取城市的td
            city_td = tds[1]
            # 获取到城市的a元素
            city_links = city_td.xpath(".//a")


            for city_link in city_links:
                # 城市
                city = city_link.xpath(".//text()").get()  # get方法相当于取列表第0个元素.extract()
                item['city'] = city
                # 城市的链接
                city_url = city_link.xpath(".//@href").get()
                # 以点分割城市的链接
                city_url_list = city_url.split('.')
                # 拼接城市二手房链接
                esfhouse_url = city_url_list[0] + '.esf.' + city_url_list[1] + '.' + city_url_list[2]
                item['esfhouse_url'] = esfhouse_url
                # 这里dict比较关键，因为我们只初始化了一次item = UrlItem()，对python底层实现不是很清楚，但如果不转化会重复append相同item对象。
                city_lis.append(dict(item))
        return city_lis
```

所以这里return给谁了呢？与Scrapy框架图对应起来，return给了引擎，对应第7步，尝试在此直接输出到文件而**==不经过pipline==**。

### 简单爬虫的持久化存储

```bash
scrapy crawl esf -o esf_url.json
```

打开esf_url.json查看如下，json后缀默认中文为Unicode编码格式，csv和xml默认为utf-8编码格式

> ```
> 
> [
> {"province": "\u5b89\u5fbd", "city": "\u5408\u80a5", "esfhouse_url": "http://hf.esf.fang.com/"},
> {"province": "\u5b89\u5fbd", "city": "\u829c\u6e56", "esfhouse_url": "http://wuhu.esf.fang.com/"},
> {"province": "\u5b89\u5fbd", "city": "\u6dee\u5357", "esfhouse_url": "http://huainan.esf.fang.com/"},
> {"province": "\u5b89\u5fbd", "city": "\u868c\u57e0", "esfhouse_url": "http://bengbu.esf.fang.com/"},
> {"province": "\u5b89\u5fbd", "city": "\u961c\u9633", "esfhouse_url": "http://fuyang.esf.fang.com/"},
> ……
> ]
> ```

```
scrapy crawl esf -o esf_url.csv
```

> ```
> city,esfhouse_url,province
> 北京,http://bj.esf.fang.com/,直辖市
> 上海,http://sh.esf.fang.com/,直辖市
> ……
> ```

```
scrapy crawl esf -o esf_url.xml
```

> ```
> <?xml version="1.0" encoding="utf-8"?>
> <items>
> <item><province>直辖市</province><city>北京</city><esfhouse_url>http://bj.esf.fang.com/</esfhouse_url></item>
> <item><province>直辖市</province><city>上海</city><esfhouse_url>http://sh.esf.fang.com/</esfhouse_url></item>
> ……
> ```

老老实实存下来了，在此其实一个简单的爬虫就写好了，如果你只是要这个页面上的链接的话，已经完成了，然而这种写法难以进行写入数据库等存储操作，后续就要用到Pipline机制了。

### 使用Scrapy的Pipline机制进行持久化存储。

我们这里尝试使用yield方法返回item，改写爬虫类中的parse方法如下。（yield方法的使用与return显式区别是yield不会终止本程序运行，如果函数里有yield，且它在循环里，下次调用函数的时候，会直接从循环的下一次开始，而不是像return一样从函数从头到尾执行。更为详细的区别参考CSDN上的这篇[博客](https://blog.csdn.net/mieleizhi0522/article/details/82142856)）

```python
def parse(self, response):
    item = UrlItem()
    # 获取数据的每一行tr，可能一行爲一個省份，也可能多行爲一個省份
    trs = response.xpath("//*[@id='senfe']//tr")

    # print(trs)
    for tr in trs:
        # 获取省份的td
        tds = tr.xpath(".//td[not(@class)]")  # "not(@class)" ：没有为class赋值的被选取
        province_td = tds[0]
        # #获取省份的值
        province_text = province_td.xpath(".//text()").get()
        # #给省份去掉 多余空格
        province_text = re.sub(r'\s', '', province_text)
        # 判断省份是否为空的
        if province_text:
            # 将不为空的省份赋值给province
            province = province_text
            # 除去国外的链接
            if province == '其它':
                break
            # 除去直辖市中的重庆和天津，因为在文中有写到
            if province == '重庆' or province == '天津':
                continue
            item['province'] = province

        # 获取城市的td
        city_td = tds[1]
        # 获取到城市的a元素
        city_links = city_td.xpath(".//a")

        for city_link in city_links:
            # 城市
            city = city_link.xpath(".//text()").get()  # get方法相当于取列表第0个元素.extract()
            item['city'] = city
            # 城市的链接
            city_url = city_link.xpath(".//@href").get()
            # 以点分割城市的链接
            city_url_list = city_url.split('.')
            # 拼接城市二手房链接
            esfhouse_url = city_url_list[0] + '.esf.' + city_url_list[1] + '.' + city_url_list[2]
            item['esfhouse_url'] = esfhouse_url

            # 返回提取到的每个item给pipline，处理完成之后继续执行后面代码（下一个循环）
            yield item
```

写pipline类，向piplines.py里写入如下内容

```python
from scrapy.exporters import CsvItemExporter


class ScrapyFangPipeline(object):
    url_fp = open('esf_url.csv', 'wb')
    url_exporter = CsvItemExporter(url_fp)

    def process_item(self, item, spider):
        self.url_exporter.export_item(item)

        # 返回item对象是必须的，告诉引擎item已经处理完成了，可以继续执行后面代码。
        return item

    def close_spider(self, spider):
        self.url_fp.close()
```

启用pipline，在settings.py中写入如下，300为优先级，多个管道程序(执行类中的process_item方法)按照优先级依次进行

```python
ITEM_PIPELINES = {
   'scrapy_fang.pipelines.ScrapyFangPipeline': 300,
}
```

```bash
scrapy crawl esf
```

查看生成的esf_url.csv如下

> ```
> city,esfhouse_url,province
> 北京,http://bj.esf.fang.com/,直辖市
> 上海,http://sh.esf.fang.com/,直辖市
> 天津,http://tj.esf.fang.com/,直辖市
> 重庆,http://cq.esf.fang.com/,直辖市
> ```

### 至此完成基本的Scrapy项目

基本Scrapy框架实现完成了单个页面上的数据爬取，省份，城市，链接……

## 特定城市二手房概要信息爬虫—构造URL方式

我们在本次尝试直接拼接页码得到url，观察得到，北京二手房首页URL为http://bj.esf.fang.com/，也可以在页码中写为https://bj.esf.fang.com/house/i31/，第二页就是https://bj.esf.fang.com/house/i32/，依次类推……

![image-20220505170148978](MD_img/image-20220505170148978.png)

在shell里面尝试能否抓到数据

```bash
scrapy shell https://bj.esf.fang.com/house/i31/
>>>response.xpath("//dl[@dataflag='bg']")
```

> []

抓取失败（返回空），后面分析是URL重定向的原因，网站做了防护，让网页重定向去往了另一个URL。同时，测试发现http://bj.esf.fang.com/不会进行重定向操作，而想要访问迭代的网址https://bj.esf.fang.com/house/i31/，32，33等却会进行重定向。

### 矛与盾——重定向

分析返回的response

> ```
> <a class="btn-redir" style="font-size: 14pt;" href="https://bj.esf.fang.com/house/i31/?rfss=1-a9078821a1b90b2a70-34">\xe7\x82\xb9\xe5\x87\xbb\xe8\xb7\xb3\xe8\xbd\xac</a>\r\n</div>\r\n</div>\r\n<script>\r\n(function(){\r\n  var secs=100,si=setInterval(function(){\r\n    if(!--secs){\r\n      //location.href="https://bj.esf.fang.com/house/i31/?rfss=1-a9078821a1b90b2a70-34";\r\n      clearInterval(si);\r\n    }else{\r\n      jQuery(\'.second\').text(secs);\r\n    }\r\n  }, 100)})();\r\n</script>\r\n</div>\r\n</div>\r\n\r\n<script>\r\n/* $(".guan-intro").mouseover(function(){\r\n\t$(this).parents(".guan-wrap").siblings().show();\r\n}).mouseleave(function(){\r\n\t$(this).parents(".guan-wrap").siblings().hide();\r\n}); */\r\n\r\nfunction showDiv(size,obj){\r\n\tif(size>32){\r\n\t\t$(obj).parents(".guan-wrap").siblings().show();\r\n\t}\r\n}\r\nfunction hideDiv(size,obj){\r\n\tif(size>32){\r\n\t\t$(obj).parents(".guan-wrap").siblings().hide();\r\n\t}\r\n}\r\n</script>\r\n</body>\r\n</html>'
> 
> ```

可以看到，访问https://bj.esf.fang.com/house/i31/时网页重定向去了"https://bj.esf.fang.com/house/i31/?rfss=1-a9078821a1b90b2a70-34"这个网址，我们尝试获取这个网址的response。

```bash
scrapy shell https://bj.esf.fang.com/house/i31/?rfss=1-a9078821a1b90b2a70-34
>>>response.xpath("//dl[@dataflag='bg']")
```

> ```
> [<Selector xpath="//dl[@dataflag='bg']" data='<dl class="clearfix" dataflag="bg" da...'>, <Selector xpath="//dl[@dataflag='bg']" data='<dl class="clearfix" dataflag="bg" da...'>, <Selector xpath="//dl[@dataflag='bg']" data='<dl class="clearfix" dataflag="bg" da...'>, <Selector xpath="//dl[@dataflag='bg']" data='<dl class="clearfix" dataflag="bg" da...'>, <Selector ……]
> ```

抓取成功了，后续将想法在中间件中实现。



### Item.py

```python
#二手房页面的Item
class EsfItem(scrapy.Item):
      # 省份
      province = scrapy.Field()
      # 城市
      city = scrapy.Field()
      #二手房的标题
      title = scrapy.Field()
      # 二手房详细信息的链接
      esfhousenews_url = scrapy.Field()
      # 户型
      room_type = scrapy.Field()
      # 面积
      area = scrapy.Field()
      # 楼层
      floor = scrapy.Field()
      # 朝向
      orientation = scrapy.Field()
      # 建筑时间
      build_year = scrapy.Field()
      # 小区名字
      village_name = scrapy.Field()
      # 地址
      address = scrapy.Field()
      # 总价
      total = scrapy.Field()
      #每平米的价格
      unit = scrapy.Field()
```

### esf.py

```python
import scrapy
import re
from scrapy_fang.items import UrlItem, EsfItem
class EsfSpider(scrapy.Spider):
    # 别名，后续用来其启动爬虫
    name = 'esf'
    # 允许爬取的页面
    allowed_domains = ['fang.com']
    # 启动爬取的页面
    base_url = 'https://bj.esf.fang.com/house/i3%d/'
    offset = 1
    start_urls = ['https://bj.esf.fang.com']
    # 总页数，解析赋值
    page_num = 1
    get_page_num_flag = True

    # Scrapy框架默认调用这个方法。response.body是html源码
    def parse(self, response):
        # 初次执行会进入，后续不进入
        if self.get_page_num_flag:
            # 获取总页码
            page_num_text = response.xpath("//div[@class='page_al']/span/text()")[-1].get()
            # 将不是数字的替换为空
            page_num = re.sub('\D', '', page_num_text)
            page_num = int(page_num)
            self.page_num = page_num
            self.get_page_num_flag = False
        print(
                "-------------------------------------------------对于二手房页面的解析--------------------------------------------------")

        dls = response.xpath("//dl[@class='clearfix']")
        for dl in dls:
            item = EsfItem()
            item['province'] = '直辖市'
            item['city'] = '北京'
            item['build_year'] = ''
            # 二手房标题
            title = dl.xpath(".//h4[@class='clearfix']/a/@title").get()
            item['title'] = title
            # 二手房详情链接
            esfhousenews_url_text = dl.xpath(".//h4[@class='clearfix']/a/@href").get()
            esfhousenews_url = response.urljoin(esfhousenews_url_text)
            # print(esfhousenews_url)
            item['esfhousenews_url'] = esfhousenews_url
            # 二手房信息
            lists = "".join(dl.xpath(".//p[@class='tel_shop']/text()").getall()).split()
            for list in lists:
                if '室' in list:
                    # 户型
                    item['room_type'] = list
                elif '㎡' in list:
                    # 面积
                    item['area'] = list
                elif '层' in list:
                    # 楼层
                    item['floor'] = list
                elif '向' in list:
                    # 朝向
                    item['orientation'] = list
                elif '年' in list:
                    # 建筑时间
                    item['build_year'] = list

            # 小区名字
            village_name = dl.xpath(".//p[@class='add_shop']/a/@title").get()
            item['village_name'] = village_name

            # 地址
            address = dl.xpath(".//p[@class='add_shop']/span/text()").get()
            item['address'] = address

            # 总价
            total_price = dl.xpath(".//dd[@class='price_right']/span[@class='red']/b/text()").get()
            item['total'] = total_price
            unit_price = dl.xpath(".//dd[@class='price_right']/span[not(@class)]/text()").get()
            # 每平方米的价格
            item['unit'] = unit_price
            yield item
        # 下一页的链接
        if self.offset < self.page_num:
            self.offset += 1
            next_link = self.base_url % self.offset
            # 跳到下一页
            yield scrapy.Request(url=next_link, callback=self.parse)
```

### middlewares.py

```python
import requests
import random
from scrapy.http import HtmlResponse

# 模拟浏览器请求头
class UserAgentDownloadMiddleware(object):

    User_Agents = [
            'Mozilla/5.0 (X11; Linux i686; rv:64.0) Gecko/20100101 Firefox/64.0',
            'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.13; ko; rv:1.9.1b2) Gecko/2008'
            '1201 Firefox/60.0',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)'
            ' Chrome/70.0.3538.77 Safari/537.36',
            'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML like Gecko) Chrome'
            '/44.0.2403.155 Safari/537.36',
        ]

    # 随机请求头
    def process_request(self, request, spider):
        User_Agent = random.choice(self.User_Agents)
        request.headers['User-Agent'] = User_Agent
        return None


# 处理URL重定向问题
class ProcessRedirectionMiddleware(object):
    User_Agents = [
            'Mozilla/5.0 (X11; Linux i686; rv:64.0) Gecko/20100101 Firefox/64.0',
            'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.13; ko; rv:1.9.1b2) Gecko/2008'
            '1201 Firefox/60.0',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)'
            ' Chrome/70.0.3538.77 Safari/537.36',
            'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML like Gecko) Chrome'
            '/44.0.2403.155 Safari/537.36',
        ]

    def process_response(self, request, response, spider):
        User_Agent = random.choice(self.User_Agents)
        # 从response的body中提取重定向的网址

        redirected_url = response.selector.xpath("//a[@class='btn-redir']//@href").get()
        # 如果抓取成功，则说明进行了重定向，返回目标网址的response
        if redirected_url:
            response = requests.get(redirected_url, headers={'User_Agent': User_Agent})

            # 构造scrapy的response对象。
            return HtmlResponse(url=redirected_url, body=response.content)

        # 否则返回原response
        return response
```

### settings.py

```python
# 下载器中间件，添加请求头，处理重定向
DOWNLOADER_MIDDLEWARES = {
   'scrapy_fang.middlewares.UserAgentDownloadMiddleware': 543,
   'scrapy_fang.middlewares.ProcessRedirectionMiddleware': 553,
}

# 指定Pipline，本流程用于保存yield的item数据
ITEM_PIPELINES = {
   'scrapy_fang.pipelines.ScrapyFangPipeline': 300,
}

# 允许爬虫缓存（不会重复请求目标页面，一次请求成功后，会存在缓存中，减小网站压力。）
HTTPCACHE_ENABLED = True
HTTPCACHE_EXPIRATION_SECS = 0
HTTPCACHE_DIR = 'httpcache'
HTTPCACHE_IGNORE_HTTP_CODES = []
HTTPCACHE_STORAGE = 'scrapy.extensions.httpcache.FilesystemCacheStorage'

# 是否遵循robots协议
ROBOTSTXT_OBEY = False

# Configure maximum concurrent requests performed by Scrapy (default: 16)
CONCURRENT_REQUESTS = 32

# 延时最低为0
DOWNLOAD_DELAY = 0
```

### pipelines.py

```python
from scrapy.exporters import CsvItemExporter


class ScrapyFangPipeline(object):
    esf_info_fp = open('esf_info.csv', 'wb')
    esf_info_exporter = CsvItemExporter(esf_info_fp)

    def process_item(self, item, spider):
        self.esf_info_exporter.export_item(item)

        # 返回是必须的，告诉引擎item已经处理完成了，可以继续执行后面代码。
        return item
    def close_spider(self, spider):
        self.esf_info_fp.close()
```

### 启动爬虫

```bash
scrapy crawl esf
```

### 获得爬得数据

![image-20220506104545674](MD_img/image-20220506104545674.png)

## 多城市二手房详情页爬虫——下一页URL获取方式

## selenium模拟拖动验证码

使用时间戳命名来保存拖动的背景图片和目标图片，并用opencv来识别边界，获取准确的像素坐标，使用driver模拟拖动动作，完成验证码绕过。(如果需要高匿性质服务，建议挂上代理，由于要下载图片以及模拟网页操作，建议上稳定延迟的爬虫，最好带宽也大些，本次项目就直接用本地网络解了，未挂代理，因为我能保证本地是稳定的，当然，你也可以自己测开放代理池择优拿来用。)

<img src="MD_img/iShot2022-05-09_16.40.32.png" alt="iShot2022-05-09_16.40.32" style="zoom:50%;" />

<img src="MD_img/image-20220511204336061.png" alt="image-20220511204336061" style="zoom: 80%;" />

**类定义如下**

```
class DealCaptcha():
    def __init__(self):
        self.dir_path = '/home/oliver/PycharmProjects/scrapy_fang/img/'
        options = webdriver.ChromeOptions()
        options.add_argument('user-agent=Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:55.0) Gecko/20100101 Firefox/55.0')
        proxy = random.choice(pro.proxy_list)
        proxy_ip, proxy_port = proxy.split(':')
        proxyauth_plugin_path = self.create_proxyauth_extension(
            proxy_host=proxy_ip,  # 代理IP
            proxy_port=proxy_port,  # 端口号
            # 用户名密码(私密代理/独享代理)
            proxy_username=pro.username,
            proxy_password=pro.password
        )
        options.add_extension(proxyauth_plugin_path)



        self.bg_jpg_path = self.dir_path + hashlib.md5(str(time.time()).encode("UTF-8")).hexdigest() + 'bg.jpg'
        self.block_png_path = self.dir_path + hashlib.md5(str(time.time()).encode("UTF-8")).hexdigest() + 'block.png'
        self.driver = webdriver.Chrome(chrome_options=options, executable_path='/usr/local/driver/chromedriver',)  # desired_capabilities=caps)
        self.driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
            "source": """
                Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined
                })
            """
        })

    def create_proxyauth_extension(self, proxy_host, proxy_port, proxy_username, proxy_password, scheme='http',
                                   plugin_path=None):
        """代理认证插件

        args:
            proxy_host (str): 你的代理地址或者域名（str类型）
            proxy_port (int): 代理端口号（int类型）
            # 用户名密码认证(私密代理/独享代理)
            proxy_username (str):用户名（字符串）
            proxy_password (str): 密码 （字符串）
        kwargs:
            scheme (str): 代理方式 默认http
            plugin_path (str): 扩展的绝对路径

        return str -> plugin_path
        """

        if plugin_path is None:
            plugin_path = self.dir_path + 'vimm_chrome_proxyauth_plugin.zip'

        manifest_json = """
        {
            "version": "1.0.0",
            "manifest_version": 2,
            "name": "Chrome Proxy",
            "permissions": [
                "proxy",
                "tabs",
                "unlimitedStorage",
                "storage",
                "<all_urls>",
                "webRequest",
                "webRequestBlocking"
            ],
            "background": {
                "scripts": ["background.js"]
            },
            "minimum_chrome_version":"22.0.0"
        }
        """

        background_js = string.Template(
            """
            var config = {
                    mode: "fixed_servers",
                    rules: {
                    singleProxy: {
                        scheme: "${scheme}",
                        host: "${host}",
                        port: parseInt(${port})
                    },
                    bypassList: ["foobar.com"]
                    }
                };

            chrome.proxy.settings.set({value: config, scope: "regular"}, function() {});

            function callbackFn(details) {
                return {
                    authCredentials: {
                        username: "${username}",
                        password: "${password}"
                    }
                };
            }

            chrome.webRequest.onAuthRequired.addListener(
                        callbackFn,
                        {urls: ["<all_urls>"]},
                        ['blocking']
            );
            """
        ).substitute(
            host=proxy_host,
            port=proxy_port,
            username=proxy_username,
            password=proxy_password,
            scheme=scheme,
        )
        with zipfile.ZipFile(plugin_path, 'w') as zp:
            zp.writestr("manifest.json", manifest_json)
            zp.writestr("background.js", background_js)
        return plugin_path

    def get_captcha(self):
        # 背景图片
        bg = self.driver.find_element(by=By.CLASS_NAME, value="img-bg").get_attribute('src')
        with open(self.bg_jpg_path, mode='wb') as f:
            f.write(requests.get(bg).content)
        # 滑动图片
        block = self.driver.find_element(by=By.CLASS_NAME, value='img-block').get_attribute('src')
        with open(self.block_png_path, mode='wb') as f:
            f.write(requests.get(block).content)

        image = cv2.imread(self.block_png_path, cv2.IMREAD_UNCHANGED)  # 读取图片
        # cv2.imshow('1', image)
        # 保存裁剪后图片
        box = self.get_transparency_location(image)
        result = self.cv2_crop(image, box)
        cv2.imwrite(self.block_png_path, result)

    def move_to_gap(self, tracks):
        # 移动滑块
        drop = self.driver.find_element(by=By.CLASS_NAME, value="verifyicon")
        ActionChains(self.driver).click_and_hold(drop).perform()
        for x in tracks:
            ActionChains(self.driver).move_by_offset(xoffset=x, yoffset=0).perform()
        time.sleep(0.5)
        ActionChains(self.driver).release().perform()

    def cv2_crop(self, im, box):
        '''cv2实现类似PIL的裁剪

        :param im: cv2加载好的图像
        :param box: 裁剪的矩形，(left, upper, right, lower)元组
        '''
        return im.copy()[box[1]:box[3], box[0]:box[2], :]

    def get_transparency_location(self, image):
        '''获取基于透明元素裁切图片的左上角、右下角坐标

        :param image: cv2加载好的图像
        :return: (left, upper, right, lower)元组
        '''
        # 1. 扫描获得最左边透明点和最右边透明点坐标
        height, width, channel = image.shape  # 高、宽、通道数
        assert channel == 4  # 无透明通道报错
        first_location = None  # 最先遇到的透明点
        last_location = None  # 最后遇到的透明点
        first_transparency = []  # 从左往右最先遇到的透明点，元素个数小于等于图像高度
        last_transparency = []  # 从左往右最后遇到的透明点，元素个数小于等于图像高度
        for y, rows in enumerate(image):
            for x, BGRA in enumerate(rows):
                alpha = BGRA[3]
                if alpha != 0:
                    if not first_location or first_location[1] != y:  # 透明点未赋值或为同一列
                        first_location = (x, y)  # 更新最先遇到的透明点
                        first_transparency.append(first_location)
                    last_location = (x, y)  # 更新最后遇到的透明点
            if last_location:
                last_transparency.append(last_location)

        # 2. 矩形四个边的中点
        top = first_transparency[0]
        bottom = first_transparency[-1]
        left = None
        right = None
        for first, last in zip(first_transparency, last_transparency):
            if not left:
                left = first
            if not right:
                right = last
            if first[0] < left[0]:
                left = first
            if last[0] > right[0]:
                right = last

        # 3. 左上角、右下角
        upper_left = (left[0], top[1])  # 左上角
        bottom_right = (right[0], bottom[1])  # 右下角

        return upper_left[0], upper_left[1], bottom_right[0], bottom_right[1]

    def template_matching(self, bg, block):
        # 读取目标图片
        target = cv2.imread(bg)
        # 读取模板图片
        template = cv2.imread(block)
        # 获得模板图片的高宽尺寸
        theight, twidth = template.shape[:2]
        # 执行模板匹配，采用的匹配方式cv2.TM_SQDIFF_NORMED
        # result = cv2.matchTemplate(target,template,cv2.TM_SQDIFF_NORMED)
        result = cv2.matchTemplate(target, template, cv2.TM_SQDIFF_NORMED)

        # 归一化处理
        cv2.normalize(result, result, 0, 1, cv2.NORM_MINMAX, -1)
        # 寻找矩阵（一维数组当做向量，用Mat定义）中的最大值和最小值的匹配结果及其位置
        min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)
        return min_loc[0], min_loc[1]

    def get_track(self, distance):
        """
        根据偏移量获取移动轨迹
        :param distance: 偏移量
        :return: 移动轨迹
        相关公式：
        x = x0 * t + 0.5 * a * t * t
        v = v0 + a * t
        """
        v = 0  # 初速度
        t = 2  # 单位时间为0.2s来统计轨迹，轨迹即0.2内的位移
        tracks = []  # 位移/轨迹列表，列表内的一个元素代表0.2s的位移
        current = 0  # 当前的位移
        mid = distance * 4 / 5  # 到达mid值开始减速
        distance += 10  # 先滑过一点，最后再反着滑动回来

        while current < distance:
            if current < mid:
                # 加速度越小，单位时间的位移越小,模拟的轨迹就越多越详细
                a = 2  # 加速运动
            else:
                a = -3  # 减速运动
            v0 = v  # 初速度
            s = v0 * t + 0.5 * a * (t ** 2)  # 0.2秒时间内的位移
            current += s  # 当前的位置
            tracks.append(round(s))  # 添加到轨迹列表
            v = v0 + a * t  # 速度已经达到v,该速度作为下次的初速度

        # 反着滑动到大概准确位置
        for i in range(3):
            tracks.append(-2)
        for i in range(4):
            tracks.append(-1)
        print(tracks)
        return tracks

    def run(self, url):
        try:
            self.driver.get(url)
            # 隐式等待
            self.driver.implicitly_wait(10)
            time.sleep(2)

            verification_code = self.driver.find_element(by=By.CSS_SELECTOR, value='.info p').text
            if verification_code == "请拖动滑块进行验证：":
                sucess = self.driver.find_element(by=By.CSS_SELECTOR, value='.drag-text').text 
                print(sucess)
                # 下载验证码
                while sucess != '验证通过啦！':
                        self.get_captcha()  
                        x, y = self.template_matching(self.bg_jpg_path, self.block_png_path)
                        self.move_to_gap([x])
                        print(x, y)
                        time.sleep(2)
                        sucess = self.driver.find_element(by=By.CSS_SELECTOR, value='.drag-text').text
                        print(sucess)

                self.driver.find_element(by=By.ID, value="captcha_submit_btn").click() 
                time.sleep(1)
                Html_document = self.driver.execute_script("return document.documentElement.outerHTML")

        except:
            self.driver.close()
            return None
        self.driver.close()
        return Html_document
```



## ip代理池爬取

由于房天下的反爬机制，我们现在自行构建一个代理池，去往快代理爬取。





**列表页解析示例**

<img src="MD_img/image-20220509210916613.png" alt="image-20220509210916613" style="zoom: 67%;" />



