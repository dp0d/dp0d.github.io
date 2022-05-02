---
draft: true
title: "Scrapy使用案例——房天下"
subtitle: "Scrapy2.6"
date: 2022-04-09T10:40:45+08:00
lastmod: 2022-04-09T10:40:45+08:00
authors: [dp0d]
description: "爬虫应该是python使用者比较重要的一门技能，学会这个也能进厂了。"

tags: [Scrapy2.6]
categories: [tutorial]

---

## Scrapy框架overview

![scrapy_architecture_02](MD_img/scrapy_architecture_02.png)

### Scrapy结构组成



### Scrapy Engine

Scrapy引擎负责控制各组件之间的所有数据流，并在特定动作发生时触发事件。

### Scheduler

调度器接收来自引擎的请求并将它们排入队列以便后续响应引擎。（爬虫执行过程需要时间，不能同时完成所有任务，因而需要任务队列。）

### Downloader

下载器负责抓取网页并将它们喂给引擎，引擎转而喂给Spider爬虫程序。

### Spider

爬虫是由Scrapy用户自行编写的客制化类，用来解析响应以及提取网页数据项或其他请求。

### Item Pipline

负责处理由爬虫提取的数据项。典型任务包括清理数据，验证数据以及持续化存储在数据库中等。

### Downloader middlewares

下载中间件是位于引擎和下载器之间的钩子程序（可以理解为连接点），用来处理由引擎发往下载器的请求已经来自下载器发回引擎的响应。使用中间件的情景如下：



## 环境介绍

 Ubuntu 21.10,	Python3.10.3，pyenv

## Scrapy 安装

pip 更新

```bash
python -m pip install --upgrade pip
```

安装scrapy

```ba
pip install scrapy
```

创建scrapy项目

```bash
cd ~
scrapy startproject scrapy_fang
```

创建爬虫，注意爬虫名字不要和项目域名相同

```
cd scrapy_fang
scrapy genspider esf esf.fang.com
```

设置请求头(模拟浏览器访问)，在settings.py下添加，可以更换，随便打开一个网页，F12查看network，然后找一下User-Agent内容。

```python
USER_AGENT  = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.60 Safari/537.36'
```



编写spiders目录下的`esf.py`

```python
def parse(self, response)
	title = response.xpath('/html/head/title').extract()
	print(title)

```



