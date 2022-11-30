---
draft: false
title: "小解一波准召率"
subtitle: "这个就像一个程序，理解了混淆矩阵，自然理解准召率了，本文通过一张图让你轻松理解混淆矩阵的内涵！"
date: 2022-11-30T10:50:18+08:00
lastmod: 2022-11-30T10:50:18+08:00
description: ""

tags: [] # env linux mac py tools win task
categories: [] # tutorial, technology_log, machine_learning, nlp
series: [] # python_data_analysis, jupyter, data_science_contest

toc:
  enable: true
math:
  enable: true
license: ""
---

## 混淆矩阵

<img src="MD_img/confusion matrix.png" alt="confusion_matrix"  />

## 精确率 Precision（通常指micro）

$$
Precision = \frac{TP}{TP+FP}
$$



## 查全率 Recall

$$
Recall = \frac{TP}{TP+FN}
$$

## F1 (查准率和查全率的调和平均数)

$$
F1 = \frac{2\cdot Precision \cdot Recall}{Precision+Recall}
$$



