---
draft: false
title: "Python项目包引用与环境设置"
subtitle: ""
date: 2022-05-20T14:43:54+08:00
lastmod: 2022-05-20T14:43:54+08:00
description: ""

tags: [py, linux] # env linux mac py tools win
categories: [technology_log] # tutorial, technology_log, machine_learning
series: []

toc:
  enable: true
math:
  enable: true
license: ""
---

## 说明

通常，我们在项目中，需要把代码文件作为一个包来用，比如代码文件是code文件夹，如果使用Pycharm等IDE，只需要在里面加入一个空的![image-20220520144647092](MD_img/image-20220520144647092.png)文件来说明这是一个包文件，就能在与code文件夹的同级目录下import code了，然而， 如果直接在系统环境下，却常常会报找不到这个包，解决方法如下

## 项目入口是py文件

在py文件顶端加入如下代码

```
import sys
project_path = '/home/mw/project'  # 这里设置自己的项目路径
sys.path.append(project_path) 
from code import *
import code
```

如果报错：ModuleNotFoundError: No module named code code is not a package，在考虑有没有进入code同级目录下的同时，是否系统环境中含有code名字冲突等，更换自己的代码文件夹code为mycode等名字来解决。

```
import sys
project_path = '/home/mw/project'  # 这里设置自己的项目路径
sys.path.append(project_path) 
from mycode import *
import mycode
```



## 项目入口是sh文件

在sh文件顶部加上如下代码，将当前项目目录加入PYTHON环境变量。

```
# 导入当前项目作为环境变量
project_path="$(pwd)"
export PYTHONPATH=$project_path:$PYTHONPATH
echo $PYTHONPATH
source $HOME/.bashrc
```
