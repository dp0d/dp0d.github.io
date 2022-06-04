---
draft: false
title: "Kaggle使用介绍"
subtitle: ""
date: 2022-06-04T10:03:26+08:00
lastmod: 2022-06-04T10:03:26+08:00
description: ""

tags: [] # env linux mac py tools win task
categories: [] # tutorial, technology_log, machine_learning, nlp
series: [data_science_contest] # python_data_analysis, jupyter, data_science_contest

toc:
  enable: true
math:
  enable: true
license: ""
---

## 命令行的使用

### Kaggle API 安装

+ 第一步，本地

```bash
pip install kaggle
```

+ 第二步，kaggle

点击头像->Account->API->Create New API Token（如果想要删除以往使用过的Token可以点击API下的Expire API Token）

+ 第三步，本地

把下载的kaggle.json放在用户根目录的.kaggle/文件夹下

安装完成。



### 关于数据集

数据集可以用来上传本地的数据以及在本地训练好的模型文件。

#### 创建并上传数据集

+ 第一步，本地初始化 ，将data_dir换成你自己的路径名字

```bash
kaggle datasets init -p 'data_dir'
```

+ 第二步，数据集改名

第一步之后会在data_dir目录下生成一个dataset-metadata.json文件内容如下，把title和id中的title部分改成你想要的名字，比如我改为了best-model。

```json
{
  "title": "best-model",
  "id": "oliverlionado/best-model",
  "licenses": [
    {
      "name": "CC0-1.0"
    }
  ]
}
```

+ 第三步，上传数据集

```
kaggle datasets create -p model_data/
```

然后你的数据集里就会出现一个新的数据集，以本例为例，数据集名字叫做best-model，里面的内容就是model_data/目录下的文件（不含model_data/文件夹）。

#### 更新某个数据集

比如我想使用model_data/文件夹下的文件去更新

```bash
kaggle datasets version -p model_data/  -m "update"
```

注意——如果你想更新一个不是在当前目录下创建的数据集（目录里没有dataset-metadata.json文件）

首先你需要下载json文件

```bash
kaggle datasets metadata -p model_data/ oliverlionado/best-model
```

其中oliverlionado/best-model指的是已存在数据集的id

然后再执行上一条命令~
