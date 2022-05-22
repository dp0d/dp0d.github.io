---
draft: false
title: "Jupyter使用教程"
subtitle: ""
date: 2022-05-22T21:52:26+08:00
lastmod: 2022-05-22T21:52:26+08:00
description: ""

tags: [py, tools] # env linux mac py tools win
categories: [tutorial] # tutorial, technology_log, machine_learning
series: []

toc:
  enable: true
math:
  enable: true
license: ""
---

Jupyter 已经被人们广泛使用来作为开发，由于其能够步运行和可视化等，带来了良好的教学和交互体验。

## Jupyter Lab

### 设置代理

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

然后每次启动之前就会运行这个文件，不难知道，直接在jupyter的开头写上这句也有效。

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
