---
draft: false
title: "深度学习优化策略"
subtitle: ""
date: 2022-05-18T15:20:58+08:00
lastmod: 2022-05-18T15:20:58+08:00
description: ""

tags: [] # env linux mac py tools win
categories: [machine_learning] # tutorial
series: []

toc:
  enable: true
math:
  enable: true
license: ""
---

## 训练优化策略

### 梯度裁剪

梯度裁剪策略是解决模型训练过程中梯度爆炸策略的一个有效方法，为什么会导致梯度爆炸呢？我们知道，如果模型如下
$$
f(x)=wx+b
$$
省略b的情况下，梯度$\Delta = x$,当$x$值过大情况下，则可能会发生梯度爆炸现象，这时，我们可以对梯度进行裁剪，使之规范在指定范围内，如此一来可避免类似现象。

