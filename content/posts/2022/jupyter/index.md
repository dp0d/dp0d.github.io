---
draft: false
title: "Jupyter使用教程"
subtitle: ""
date: 2022-05-22T21:52:26+08:00
lastmod: 2022-05-22T21:52:26+08:00
description: ""

tags: [py, tools] # env linux mac py tools win
categories: [tutorial] # tutorial, technology_log, machine_learning
series: [jupyter] #jupyter

toc:
  enable: true
math:
  enable: true
license: ""
---

Jupyter 已经被人们广泛使用来作为生产力工具，由于其能够步运行和可视化等，带来了良好的教学和交互体验。

## Jupyter Lab

### 安装和配置

#### 安装

```python
pip install jupyterlab
```

#### 配置

> 命令行指定

```bash
jupyter lab 
--allow-root 																								# 允许root权限
--no-browser 																								# 启动不打开窗口
--ip '*'                                                    # 不指定IP
--port '8889'                                               # 指定开放端口
/home/oliver/CONTEST/kaggle_patent_phrase_matching2022      # 指定启动目录

--config='~/.jupyter/jupyter_notebook_config_special.py'    # 指定配置文件(以上配置都可以写入此)
```

> 设置登录密码

```bash
jupyter lab password
```

生成配置文件，运行后一般在~/.jupyter目录下会生成

```python
jupyter lab --generate-config
```

jupyterlab配置文件设置

```python
c.ServerApp.allow_remote_access = True  # 允许远程登录
c.ServerApp.ip = '*'									  # 不指定ip
c.LabApp.open_browser = False           
c.ServerApp.allow_root = True
c.ServerApp.notebook_dir = '/home/' # 启动目录
"""
>>> from notebook.auth import passwd
>>> passwd()
Enter password: 
Verify password: 
'argon2:$argon2id$v=19$m=10240,t=10,p=8$jlFeqL9E3EPEFV2CyPETWQ$lzw9f8pTcjmXCW1uh0K0mzeQqZsGbHeaQSv4/6BJ0ys'
"""
c.NotebookApp.password = u'argon2:$argon2id......(换成你的秘钥)' #就是把生成的密码json文件里面的一串密码放这里

```



### 设置代理

#### 方法一（便捷指数1）

不难知道，直接在jupyter的开头写上这句有效。

```python
import os
os.environ['HTTP_PROXY']="http://127.0.0.1:7890"
os.environ['HTTPS_PROXY']="http://127.0.0.1:7890"
import requests
requests.get("http://google.com")
```

> ```
> <Response [200]>
> ```

ok，正常访问。

#### 方法二（便捷指数2）

此方法设置完成后需要重新启动jupyter程序。

将这几行代码写入jupyter对应的配置文件。

```bash
vi ~/.jupyter/jupyter_lab_config.py 
```

```python
import os
os.environ['HTTP_PROXY']="http://127.0.0.1:7890"
os.environ['HTTPS_PROXY']="http://127.0.0.1:7890"
```

#### 方法三（便捷指数3）

[来源](https://www.jayakumar.org/linux/how-to-configure-httphttps-proxy-for-ipython-notebook-server/)

找了很多实现方法，以下方法有效。

因为jupyter是基于ipython模式的，所以在ipython的启动文件中创建如下文件，前缀越小代表优先级越高。

```bash
vi ~/.ipython/profile_default/startup/00-first.py
```

向其中写入

```yaml
import os
os.environ['HTTP_PROXY']="http://127.0.0.1:7890"
os.environ['HTTPS_PROXY']="http://127.0.0.1:7890"
```

然后重新运行notebook，注意要把kernel关掉重开，否则不会执行此文件。

![image-20220523092134130](MD_img/image-20220523092134130.png)

然后每次启动notebook之前就会运行这个文件。

### 将ipynb文件输出为其他格式文件

#### Html

```bash
jupyter nbconvert --to html notebook.ipynb
```

只展示markdown，适用于生成数据分析报告

```bash
jupyter nbconvert --to html --no-input data_analy_4.ipynb
```

#### Markdown

```bash
jupyter nbconvert --to markdown notebook.ipynb
```

#### PDF

```bash
jupyter nbconvert --to pdf notebook.ipynb
```

