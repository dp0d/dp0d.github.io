---
draft: false
title: "预训练模型的finetune技巧"
subtitle: ""
date: 2022-07-09T11:13:47+08:00
lastmod: 2022-07-09T11:13:47+08:00
description: ""

tags: [py] # env linux mac py tools win task
categories: [machine_learning] # tutorial, technology_log, machine_learning, nlp
series: [] # python_data_analysis, jupyter, data_science_contest

toc:
  enable: true
math:
  enable: true
license: ""
---

## 权重冻结

在使用预训练语言模型进行下游任务的微调时，有时数据量难以使得其收敛，此时我们可以选择固定住某些层的参数，使其仍然保持在预训练语料上的知识积累（通常是编码器），而仅对如分类层等进行微调。

做法如下

```python
# 方法1： 设置requires_grad = False
for param in model.parameters():
    param.requires_grad = False

#  方法2： torch.no_grad()
class net(nn.Module):
    def __init__():
        ......
        # 方法1可以在此设置进行初始化。
    def forward(self.x):
        with torch.no_grad():  # no_grad下参数不会迭代 
            x = self.layer(x)
            ......
        x = self.fc(x)
        return x

```



## 参考链接

https://zhuanlan.zhihu.com/p/524036087
