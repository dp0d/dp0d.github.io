---
draft: true
title: "Scrapy使用案例——房天下"
subtitle: ""
date: 2022-04-09T10:40:45+08:00
lastmod: 2022-04-09T10:40:45+08:00
authors: [dp0d]
description: ""

tags: [Scrapy]
categories: [tutorial]

---

# 环境介绍

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



