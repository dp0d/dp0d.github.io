# Scrapy实战案例——房天下


## Scrapy框架概览

Scrapy使用了Twisted异步网络框架来处理网络通讯，可以加快我们的下载速度，不用自己去实现异步框架，并且包含了各种中间件接口，可以灵活完成各种需求。



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

+ **简略框架**

![scrapy_architecture_01](MD_img/scrapy_architecture_01.png)

+ **详细框架**

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
op2=>operation: 进入每个城市对应的二手房源列表页面。
op3=>operation: 进入列表页每个二手房的详情页。
e=>end: 结束
st->op1->op2->op3->e

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

## 特定城市二手房概要信息爬虫

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

## 多城市二手房详情页爬虫

### 完整爬取流程

<center>从城市页拿到各城市二手房链接页的基础URL</center>

![image-20220517091511727](MD_img/image-20220517091511727.png)

![image-20220517091617896](MD_img/image-20220517091617896.png)

<center>进入列表页拿到基本信息以及指向详情页的URL</center>

![image-20220517092051387](MD_img/image-20220517092051387.png)

![image-20220517091617896](MD_img/image-20220517091617896.png)

<center>从详情页获取有关二手房的详情信息</center>

![image-20220517092606171](MD_img/image-20220517092606171.png)

![image-20220517092635138](MD_img/image-20220517092635138.png)

![image-20220517092712483](MD_img/image-20220517092712483.png)



### 矛与盾

由于网站的防护，房天下网站有一系列反爬机制，有些隐藏的很深，也是通过实践才发现的。本节主要介绍作者对于反爬验证的主要解决方法，robot协议，延时爬取这种就不在这里展开详细阐述了。

#### IP代理

IP代理是爬虫的一个关键技术，通常情况下，网站会通过同一个IP地址的并发请求量来判断这是否为一个爬虫，因此，IP代理便可以使用其他代理IP进行请求的转发，来隐藏发出请求的原始IP，以达到持续爬取而不被检测到的目的。接下来介绍尝试过的两种IP代理方法。

+ **IP代理池方法**

  简述：通过向代理商获取一定数量的IP作为代理池，每次请求使用代理池其中的一个IP进行转发。在请求时进行代理，创建IP代理中间件方法如下

  ```python
  class ProxyDownloaderMiddleware:
      def process_request(self, request, spider):
          proxy = pro.get_next_proxy()
          request.meta['proxy'] = "http://%(proxy)s" % {'proxy': proxy}
          print("*****************使用代理*****************")
          print("***", proxy, "***")
          print("*****************************************")
          # 用户名密码认证(私密代理/独享代理)
          request.headers['Proxy-Authorization'] = basic_auth_header('a15179737600', 'p8x7284f')  # 白名单认证可注释此行
          return None
  ```

  获取IP代理池程序（每过60s获取一次），从服务商获取到可用的IP列表之后，我们也可以自行进行可用性检测，以免所使用的代理IP无效。本人采用的方法是使用代理IP访问http://icanhazip.com，此网站会返回当前的IP地址，如果状态码为200表明成功访问，于是成功加入代理池。

  ```python
  # -- coding: utf-8 --
  import time
  import threading
  import requests
  
  from scrapy import signals
  
  # 提取代理IP的api
  api_url = 'https://dps.kdlapi.com/api/getdps/?orderid=965208072230596&num=10&signature=bqcsohuyc0qcmz1446bn3jt234sbcezq&pt=1&format=json&sep=1'
  foo = True
  
  class Proxy:
  
      def __init__(self, ):
          self.api_url = api_url
          self.username = 'a15179737600'
          self.password = 'p8x7284f'
          self._proxy_list = self.get_proxy_lis()
  
      def get_proxy_lis(self):
  
          print(
              "-------------------------------------------------从代理商获取IP代理池--------------------------------------------------")
          proxy_lis = requests.get(self.api_url).json().get('data').get('proxy_list')
          print(
              "-------------------------------------------------获取成功，开始测试IP代理池--------------------------------------------------")
          
          # 测试连通性
          proxy_lis = [proxy for proxy in proxy_lis if self.verification(proxy)]
          
          # 可用代理列表长度为零则重新获取
          while not len(proxy_lis):
              print(
                  "-------------------------------------------------可用IP代理获取失败，重新获取中------------\
                  --------------------------------------")
              proxy_lis = requests.get(self.api_url).json().get('data').get('proxy_list')
              print(
                  "-------------------------------------------------开始测试新获IP代理池--------------------------------------------------")
          
              # 测试连通性
              proxy_lis = [proxy for proxy in proxy_lis if self.verification(proxy)]
          print(
              "-------------------------------------------------成功获得可用IP代理池（大小为%d）如下--------------------------------------------------" % len(proxy_lis))
          print(proxy_lis)
          self.index_ = 1
  
          return proxy_lis
  
      def get_next_proxy(self):
          self.index_ += 1
          proxy = self._proxy_list[self.index_ % len(self._proxy_list)]
          return proxy
  
      @property
      def proxy_list(self):
          return self._proxy_list
  
      @proxy_list.setter
      def proxy_list(self, list):
          self._proxy_list = list
  
      # 测试IP代理是否正常响应
      def verification(self, proxy):
          head = {
              'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36',
              'Connection': 'keep-alive'}
          '''http://icanhazip.com会返回当前的IP地址'''
  
          proxies = {
              "http": "http://%(user)s:%(pwd)s@%(proxy)s/" % {"user": self.username, "pwd": self.password, "proxy": proxy},
              "https": "http://%(user)s:%(pwd)s@%(proxy)s/" % {"user": self.username, "pwd": self.password, "proxy": proxy}
          }
          try:
              p = requests.get('http://icanhazip.com', headers=head, proxies=proxies, timeout=2)
              if p.status_code == 200:
                  return True
              return False
          except:
              return False
  
  
  pro = Proxy()
  print(pro.proxy_list)
  
  
  class MyExtend:
  
      def __init__(self, crawler):
          self.crawler = crawler
          # 将自定义方法绑定到scrapy信号上,使程序与spider引擎同步启动与关闭
          # scrapy信号文档: https://www.osgeo.cn/scrapy/topics/signals.html
          # scrapy自定义拓展文档: https://www.osgeo.cn/scrapy/topics/extensions.html
          crawler.signals.connect(self.start, signals.engine_started)
          crawler.signals.connect(self.close, signals.spider_closed)
  
      @classmethod
      def from_crawler(cls, crawler):
          return cls(crawler)
  
      def start(self):
          t = threading.Thread(target=self.extract_proxy)
          t.start()
  
      def extract_proxy(self):
          while foo:
              # 设置每60秒提取一次ip
              time.sleep(60)
              pro.proxy_list = pro.get_proxy_lis()
  
      def close(self):
          global foo
          foo = False
  ```

+ **TUN隧道IP代理方法**

  隧道代理是通过代理商的链接直接获取一个代理IP，可以选择每次访问切换以及每几分钟切换IP等，使用较为便捷，以下是中间件的代理方法实现。

  ```python
  # 隧道代理
  class TUNProxyDownloaderMiddleware:
  
      def process_request(self, request, spider):
          proxy = "tps553.kdlapi.com:15818"
          request.meta['proxy'] = "http://%(proxy)s" % {'proxy': proxy}
          # 用户名密码认证
          request.headers['Proxy-Authorization'] = basic_auth_header('t15209935663171', 'obs96q91')  # 白名单认证可注释此行
          request.headers["Connection"] = "close"
          return None
  ```

  在隧道代理的使用中，可以重写Retry方法（代理池操作类似），在目标页面访问失败时，更换代理IP，减小由于代理IP失效带来的影响，使得爬取的成功率更高。

  ```python
  # TUN模式更换代理
  class My_RetryMiddleware(RetryMiddleware):
      get_head = GetRandomUserAgent()
      def process_exception(self, request, exception, spider):
          if isinstance(exception, self.EXCEPTIONS_TO_RETRY):
              proxy = "tps553.kdlapi.com:15818"
              request.meta['proxy'] = "http://%(proxy)s" % {'proxy': proxy}
              # 用户名密码认证
              request.headers['Proxy-Authorization'] = basic_auth_header('t15209935663171', 'obs96q91')  # 白名单认证可注释此行
              request.headers["Connection"] = "close"
  
              UserAgent = self.get_head.agent_head()['User-Agent']
              request.headers["User-Agent"] = UserAgent
              print("出现异常%s，触发自定义重试中间件，更换ip代理" % exception, "*" * 200)
  
              return self._retry(request, exception, spider)
  ```

  

#### selenium模拟拖动，绕过验证码

在访问量大的时候，难免遇到验证码的情况，房天下久经沙场，已经拥有了很强的反爬机制。

在遇到验证码的时候，不妨使用Selenium来模拟浏览器操作，然后对通过后的页面进行解析，详细验证操作如下。

使用时间戳命名来保存拖动的背景图片和目标图片，并用opencv来识别边界，获取准确的像素坐标，使用driver模拟拖动动作，来完成验证码绕过。(如果需要高匿性质服务，建议挂上代理，由于要下载图片以及模拟网页操作，建议上稳定延迟的爬虫，最好带宽也大些，本次项目就直接用本地网络解了，未挂代理，因为我能保证本地是稳定的，当然，你也可以自己测开放代理池择优拿来用。)

在拖动的时候，为防止人机识别，模拟人拖动的操作，利用加速度公式，得到每次进行拖动的距离，分段拖动，并加入停顿设置，使得验证过程更为拟人化，提高验证的通过率。关键实现如下，通过提前为拖动指针设置轨迹来完成。

```python
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
mid = distance * 1 / 2  # 到达mid值开始减速
distance += 20  # 先滑过一点，最后再反着滑动回来

while current < distance:
    if current < mid:
        # 加速度越小，单位时间的位移越小,模拟的轨迹就越多越详细
        a = 0.1  # 加速运动
    else:
        a = -0.1  # 减速运动
    v0 = v  # 初速度
    s = v0 * t + 0.5 * a * (t ** 2)  # 0.2秒时间内的位移
    current += s  # 当前的位置
    tracks.append(round(s))  # 添加到轨迹列表
    # 实现停顿
    tracks.append(0)
    v = 0.2
    # v = v0 + a * t  # 速度已经达到v,该速度作为下次的初速度

# 反着滑动到大概准确位置
for i in range(3):
    tracks.append(-2)
for i in range(4):
    tracks.append(-1)
return tracks
```

同时，由于失败后的刷新机制，也可设置拖动次数，如果一个页面拖动不成功，我们就再试几次，因为可能遇到更好通过的图形，有助于成功验证。成功后，我们返回对HTML源码的解析得到的有关二手房详情页信息。

```python
def run(self):
    try:
        self.driver.get(self.url)
        # 隐式等待
        self.driver.implicitly_wait(10)
        time.sleep(3)
        verification_code = self.driver.find_element(by=By.CSS_SELECTOR, value='.info p').text
        if verification_code == "请拖动滑块进行验证：":
            sucess = self.driver.find_element(by=By.CSS_SELECTOR, value='.drag-text').text
            # print(sucess, '*'*200)
            # 下载验证码
            # 识别次数大于3次换页
            locate_time = 0
            while sucess != '验证通过啦！' and locate_time < 3:
                self.get_captcha()
                x, y = self.template_matching(self.bg_jpg_path, self.block_png_path)
                self.move_to_gap([x])
                print(x, y, self.url, '*' * 200)
                time.sleep(2)
                sucess = self.driver.find_element(by=By.CSS_SELECTOR, value='.drag-text').text

                # 定位次数+1
                locate_time += 1
                print("验证码循环1，-第%d次" % locate_time, '*' * 200)
                print(sucess, '*' * 200)
            self.driver.find_element(by=By.ID, value="captcha_submit_btn").click()
            time.sleep(1)
            Html_document = self.driver.execute_script("return document.documentElement.outerHTML")
            self.driver.close()
            if self.parse_target == 'page_num':
                return self.parse_page_num(Html_document)
            elif self.parse_target == 'EsfItem':
                # print(self.parse_lis_page(Html_document))
                return self.parse_lis_page(Html_document)
            elif self.parse_target == 'EsfInfoItem':
                # print(self.parse_info_page(Html_document))
                return self.parse_info_page(Html_document)
            else:
                return None
        # 刷新页面得到新图
        print('验证码处理超3次退出！', '*' * 200)
        self.driver.close()
        return None
    except Exception as ex:
        print('验证码处理异常！%s' % ex, '*' * 200)
        # 尝试关闭driver
        try:
            self.driver.close()
            return None
        except:
            return None
```



### 主要类定义

#### 爬虫文件

```python
class EsfSpider(scrapy.Spider):
    # 别名，后续用来其启动爬虫
    name = 'esf'
    # 允许爬取的页面
    allowed_domains = ['fang.com']
    # 启动爬取的页面
    start_urls = ['https://www.fang.com/SoufunFamily.htm']
    # 获取随机请求头
    get_random_UserAgent = GetRandomUserAgent()
	# 重定向链接获取方法
    def get_redirected_url(self, url):
        head = self.get_random_UserAgent.agent_head()
        # 构造scrapy的response对象。
        req_response = requests.get(url, headers=head)
        response = HtmlResponse(url=url, body=req_response.content)

        # 处理重定向
        redirected_url = response.xpath("//a[@class='btn-redir']//@href").get()

        # 如果抓取成功，则说明进行了重定向，发送一个新的请求而不是将得到的响应发给爬虫程序
        if redirected_url:
            print("重定向", redirected_url, "*" * 200)
            return redirected_url
        return url

    # Scrapy框架默认调用这个方法。response.body是html源码
    def parse(self, response):
        df = pd.read_csv('esf_info.csv')
        esfhousenews_urls = df[['esfhousenews_url']].values
        provinces = df[['province']].values
        cities = df[['city']].values
        k = 1
        for u, p, c in zip(esfhousenews_urls, provinces, cities):
            if k > 5:
                break
            esfhousenews_url = u[0]
            province = p[0]
            city = c[0]
            try:
                directed_url = self.get_redirected_url(esfhousenews_url)
                yield scrapy.Request(url=directed_url, callback=self.parse_esfhouseInfo,
                                 meta={"info": (province, city, directed_url)}, dont_filter=True)
            except Exception as ex:
                print("捕获异常%s" % ex)

    # 对于二手房详情页面的解析
    def parse_esfhouseInfo(self, response):
        province, city, esf_link = response.meta.get("info")
        print(
            "-------------------------------------------------对于%s二手房 %s 详情页的解析--------------------------------------------------" % (
                province + ' ' + city, esf_link))

        # 验证码
        response_url = str(response.url)
        print(response)

        house_info_divs = response.xpath(
            "//div[contains(@class, 'tr-line clearfix')]//div[contains(@class,'trl-item1')]")

        if 'captcha' in response_url and not house_info_divs:
            with open('captcha.txt', 'a', encoding='utf-8') as f:
                f.write(response_url + '\n')
            print('处理验证码', '*' * 200)
            deal_captcha = DealCaptcha(parse_target='EsfInfoItem', url=response_url)
            item = deal_captcha.run()
            if item:
                item['province'] = province
                item['city'] = city
                item['esf_link'] = esf_link
                return item
        elif house_info_divs:
            print('链接解析成功了', '*' * 200)
            item = EsfInfoItem()
            item['province'] = province
            item['city'] = city
            item['esf_link'] = esf_link

            title = response.xpath("//span[@class='tit_text']//text()").get()
            if title:
                item['title'] = title.strip()
            if len(house_info_divs) == 6:
                # 户型
                room_type = house_info_divs[0].xpath(".//div[@class='tt']//text()").get()
                if room_type:
                    item['room_type'] = room_type.strip()
                # 面积
                area = house_info_divs[1].xpath(".//div[@class='tt']//text()").get()
                if area:
                    item['area'] = area.strip()
                # 单价
                unit_price = house_info_divs[2].xpath(".//div[@class='tt']//text()").get()
                if unit_price:
                    item['unit_price'] = unit_price.strip()
                # 朝向
                orientation = house_info_divs[3].xpath(".//div[@class='tt']//text()").get()
                if orientation:
                    item['orientation'] = orientation.strip()
                # 楼层
                floor_info = house_info_divs[4].xpath(".//div[@class='tt']//text()").get()
                floor_info_a = house_info_divs[4].xpath(".//div[@class='tt']//a//text()").get()
                floor_type = house_info_divs[4].xpath(".//div[@class='font14']//text()").get()
                if floor_info_a and floor_type:
                    item['floor'] = floor_info_a.strip() + ',' + floor_type.strip()
                elif floor_info and floor_type:
                    item['floor'] = floor_info.strip() + ',' + floor_type.strip()
                # 装修
                decoration = house_info_divs[5].xpath(".//div[@class='tt']//text()").get()
                decoration_a = house_info_divs[5].xpath(".//div[@class='tt']/a//text()").get()
                if decoration_a:
                    item['decoration'] = decoration_a.strip()
                elif decoration:
                    item['decoration'] = decoration.strip()

            # 总价
            total_price = response.xpath("//div[contains(@class, 'price_esf')]/i//text()").get()
            if total_price:
                item['total_price'] = total_price.strip() + '万元'
            # 房源信息
            xpath_house_info_lis = response.xpath(
                "//div[contains(@class, 'content-item fydes-item')]//div[contains(@class, 'cont clearfix')]//div")
            for div in xpath_house_info_lis:
                if len(div.xpath(".//span//text()")) == 2:
                    # 建筑年代
                    if div.xpath(".//span//text()")[0].get().strip() == '建筑年代':
                        build_year = div.xpath(".//span//text()")[1].get()
                        item['build_year'] = build_year.strip()
            # 小区
            community = response.xpath("//a[@id='kesfsfbxq_A01_01_05']//text()").get()
            if community:
                item['community'] = community
            # 小区信息
            xpath_community_info_lis = response.xpath("//div[contains(@class, 'cont pt30')]")
            # 小区信息顶栏
            for div in xpath_community_info_lis.xpath(".//div[contains(@class, 'topt clearfix')]//div"):
                # 小区参考均价
                if div.xpath(".//span//text()")[0].get().strip() == '参考均价':
                    community_price = div.xpath(".//span")[1].xpath(".//i//text()").get()
                    if community_price:
                        item['community_price'] = community_price.strip() + ' 元/平米'

                # 小区均价同比去年
                if div.xpath(".//span//text()")[0].get().strip() == '同比去年':
                    community_price_to_last_year = div.xpath(".//span")[1].xpath(".//em//span//text()").get()
                    if community_price_to_last_year:
                        item['community_price_to_last_year'] = community_price_to_last_year.strip()
                # 小区均价环比上月
                if div.xpath(".//span//text()")[0].get().strip() == '环比上月':
                    community_price_to_last_month = div.xpath(".//span")[1].xpath(".//em//span//text()").get()
                    if community_price_to_last_month:
                        item['community_price_to_last_month'] = community_price_to_last_month.strip()
            for div in xpath_community_info_lis.xpath(".//div[@class='clearfix']//div"):
                if len(div.xpath(".//span")) == 2:
                    # 绿化率
                    if '绿' in div.xpath(".//span//text()")[0].get().strip():
                        plant_rate = div.xpath(".//span//text()")[1].get()
                        if plant_rate:
                            item['plant_rate'] = plant_rate.strip()
                    # 小区容积率
                    if '容' in div.xpath(".//span//text()")[0].get().strip():
                        community_volume_rate = div.xpath(".//span//text()")[1].get()
                        if community_volume_rate:
                            item['community_volume_rate'] = community_volume_rate.strip()
                    # 小区总户数
                    if '户' in div.xpath(".//span//text()")[0].get().strip():
                        community_total_family_num = div.xpath(".//span//text()")[1].get()
                        if community_total_family_num:
                            item['community_total_family_num'] = community_total_family_num.strip()
                    # 产权年限
                    if div.xpath(".//span//text()")[0].get().strip() == '产权年限':
                        property_tenure = div.xpath(".//span//text()")[1].get()
                        if property_tenure:
                            item['property_tenure'] = property_tenure.strip() + '年'
                    # 小区总楼栋数
                    if div.xpath(".//span//text()")[0].get().strip() == '总楼栋数':
                        community_total_building_num = div.xpath(".//span//text()")[1].get()
                        if community_total_building_num:
                            item['community_total_building_num'] = community_total_building_num.strip()
                    # 小区物业费用
                    if div.xpath(".//span//text()")[0].get().strip() == '物业费用':
                        community_property_expenses = div.xpath(".//span//text()")[1].get()
                        if community_property_expenses:
                            item['community_property_expenses'] = community_property_expenses.strip()
                    # 小区人车分流
                    if div.xpath(".//span//text()")[0].get().strip() == '人车分流':
                        community_people_vehicles_depart = div.xpath(".//span//text()")[1].get()
                        if community_people_vehicles_depart:
                            item['community_people_vehicles_depart'] = community_people_vehicles_depart.strip()
            return item

```

#### 管道文件

```python
class ScrapyFangPipeline(object):

    def open_spider(self, spider):
        # # URL
        self.url_fp = open('esf_url.csv', 'wb')
        self.url_exporter = CsvItemExporter(self.url_fp)

        # # 二手房信息
        self.esf_info_fp = open('esf_info.csv', 'wb')
        self.esf_info_exporter = CsvItemExporter(self.esf_info_fp)

        # 二手房详情信息
        self.esf_detail_info_fp = open('esf_detail_info.csv', 'wb')
        self.esf_detail_info_exporter = CsvItemExporter(self.esf_detail_info_fp)

    def process_item(self, item, spider):
        # # 处理URL
        if isinstance(item, UrlItem):
            print("存放二手房链接信息")
            self.url_exporter.export_item(item)

        # # 处理二手房信息
        if isinstance(item, EsfItem):
            print("存放二手房房源信息")
            self.esf_info_exporter.export_item(item)

        # 处理详情页信息
        if isinstance(item, EsfInfoItem):
            print("存放二手房房源详情信息")
            self.esf_detail_info_exporter.export_item(item)

        # 返回是必须的，告诉引擎item已经处理完成了，可以继续执行后面代码。
        return item

    def close_spider(self, spider):
        self.esf_info_fp.close()
        self.url_fp.close()
        self.esf_detail_info_fp.close()

```

#### Item文件

```python
class UrlItem(scrapy.Item):
    # 省份
    province = scrapy.Field()
    # 城市
    city = scrapy.Field()
    # 二手房链接
    esfhouse_url = scrapy.Field()


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


class EsfInfoItem(scrapy.Item):
    # 详情页链接
    esf_link = scrapy.Field()
    # 省份
    province = scrapy.Field()
    # 城市
    city = scrapy.Field()
    # 二手房的标题
    title = scrapy.Field()
    # 户型
    room_type = scrapy.Field()
    # 面积
    area = scrapy.Field()
    # 单价
    unit_price = scrapy.Field()
    # 朝向
    orientation = scrapy.Field()
    # 楼层
    floor = scrapy.Field()
    # 装修
    decoration = scrapy.Field()
    # 总价
    total_price = scrapy.Field()
    # 小区
    community = scrapy.Field()
    # 建筑年代
    build_year = scrapy.Field()
    # 绿化率
    plant_rate = scrapy.Field()
    # 产权年限
    property_tenure = scrapy.Field()
    # 小区参考均价
    community_price = scrapy.Field()
    # 小区均价同比去年
    community_price_to_last_year = scrapy.Field()
    # 小区均价同比上月
    community_price_to_last_month = scrapy.Field()
    # 小区容积率
    community_volume_rate = scrapy.Field()
    # 小区总楼栋数
    community_total_building_num = scrapy.Field()
    # 小区总户数
    community_total_family_num = scrapy.Field()
    # 小区物业费用
    community_property_expenses = scrapy.Field()
    # 小区物业费用
    community_people_vehicles_depart = scrapy.Field()
```

### 爬虫程序运行结果示例

#### 解析示例

+ **入口页解析示例**

<img src="MD_img/image-20220517104203697.png" alt="image-20220517104203697" style="zoom:67%;" />

+ **列表页解析示例**

<img src="MD_img/image-20220517104251707.png" alt="image-20220517104251707" style="zoom:67%;" />

+ **详情页解析示例**

<img src="MD_img/image-20220517104736217.png" alt="image-20220517104736217" style="zoom:67%;" />

+ **验证码通过示例**

<img src="MD_img/image-20220517200130646.png" alt="image-20220517200130646" style="zoom: 50%;" />

+ **OpenCV目标图像示例**

<img src="MD_img/iShot2022-05-09_16.40.32.png" alt="iShot2022-05-09_16.40.32" style="zoom:50%;" />

<center><img src="MD_img/image-20220511204336061.png" alt="image-20220511204336061" style="zoom: 80%;" /><img src="MD_img/6.png" alt="6" style="zoom:80%;" /><img src="MD_img/3.png" alt="3" style="zoom:80%;" /></center>

# 参考资料

+ https://www.bilibili.com/video/BV1jx411b7E3?p=1

