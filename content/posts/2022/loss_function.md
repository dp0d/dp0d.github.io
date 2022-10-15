---
draft: false
title: "损失函数"
subtitle: "实际任务中使用到的损失函数记录"
date: 2022-04-29T10:34:04+08:00
lastmod: 2022-04-29T10:34:04+08:00
description: ""

tags: [math] # env linux mac py tools win math
categories: [machine_learning] # tutorial
series: []

toc:
  enable: true
math:
  enable: true
license: ""
---

## 经典损失函数

### 相对熵（也称KL散度）

[**维基百科**](https://zh.wikipedia.org/wiki/%E7%9B%B8%E5%AF%B9%E7%86%B5)：KL散度（Kullback-Leibler divergence，简称KLD），在讯息系统中称为相对熵（relative entropy），在连续时间序列中称为随机性（randomness），在统计模型推断中称为讯息增益（information gain）。也称讯息散度（information divergence）。它是两个几率分布$P$和$Q$差别的非对称性的度量。 KL散度是用来度量使用基于$Q$的分布来编码服从$P$的分布的样本所需的额外的平均比特数，注意$P$,$Q$先后顺序。

{{< math >}}
$$
\begin{equation}
\begin{aligned}
D_{KL}(P||Q) &= -\sum_iP(i)ln\frac{Q(i)}{P(i)} \\
			&= \sum_iP(i)ln\frac{P(i)}{Q(i)}
\end{aligned}
\end{equation}
$$
{{< /math >}}

相对熵的值为非负数：


$$
D_{KL}(P||Q)\geq 0
$$
另，概率都为零时取零。





### 交叉熵——Cross Entropy



**[维基百科](https://zh.m.wikipedia.org/wiki/%E4%BA%A4%E5%8F%89%E7%86%B5)**：在信息论中，基于相同事件测度的两个概率分布$p$和$q$的交叉熵是指，当基于一个“非自然”（相对于“真实”分布$p$而言）的概率分布$q$进行编码时，在事件集合中唯一标识一个事件所需要的平均比特数（bit）。

给定两个概率分布$p$和$q$，$p$相对于$q$的交叉熵定义为：

{{< math >}}
$$
H(p,q) = E_p[-\log q] = H(p) + D_{KL}(p||q),
$$
{{< /math >}}

其中，$H(p)$是$p$的熵，$D_{KL}(p||q)$是从$p$与$q$的KL散度（也被称为$p$，相对于$q$的相对熵）。

对于离散分布$p$和$q$，交叉熵可以定义为：

{{< math >}}
$$
H(p,q)=-\sum_xp(x)\log q(x).
$$
{{< /math >}}

其中求和是指在样本空间进行计算求和。记住这个计算方法，因为后续介绍分类任务的交叉熵损失是基于此的。

#### 二分类交叉熵

假设在二分类任务时，真实标签$y$和预测标签$\hat{y}$取值空间为$\{0,1\}$。根据交叉熵定义，可以将交叉熵损失函数定义如下。
$$
J=-\frac{1}{N}\sum_{i=1}^{N}[y\log\hat{y}+(1-y)\log(1-\hat{y})]
$$
假设真实分布为$p(i)$(真实标签$y$的分布)，模型预测的分布为$q(i)$(预测标签$\hat{y}$的分布，推导如下，

{{< math >}}
$$
\begin{equation}
\begin{aligned}
H(p,q) &=-\sum_x p(x)\cdot \log({q(x)}) \\
		&=\sum_x p(x)\cdot \log(\frac{1}{q(x)})\\
		&=\sum_x p_{(y=0|x)} \cdot \log(\frac{1}{q_{(y=0|x)} }) + p_{(y=1|x)} \cdot \log(\frac{1}{q_{(y=1|x)}})\\
		&=\sum_x y\log(\frac{1}{\hat{y}}) + (1-y)\log(\frac{1}{1-\hat{y}})\\
		&=-\sum_x [y\log \hat{y} + (1-y)\log(1-\hat{y})]

\end{aligned}
\end{equation}
$$
{{< /math >}}

最后乘上$\frac{1}{N}$进行平均操作。



### 多分类交叉熵

与二分类交叉熵类似，多分类交叉熵同样是计算标签分布的熵值，基于此，我们需要把多分类考虑在内，也就是多一步求和，即每个类别上的交叉熵求和并在样本空间上进行求和，基于二分类交叉熵的参数定义，定义分类的标签种类为$n$，则多分类交叉熵损失可以表示如下
$$
\mathcal L = -\frac{1}{N}\sum_{i=1}^N\sum_{j=1}^ny_j^{(i)}\cdot \log\hat{y}_j^{(i)}
$$

### 对比损失

#### 三元损失

给定anchor $p$，以欧距为例，衡量相似度，其正样本为$q$，负样本为$r$

{{< math >}}
$$
\begin{equation}
\begin{aligned}
\mathcal L = max(||\symbfit p-\symbfit q||^2-|||\symbfit p-\symbfit r||^2+\epsilon,0)
\end{aligned}
\end{equation}
$$
{{< /math >}}

接下来介绍代码实现

> 代码实现

```python
"""
loss class
"""
class triplet_loss(nn.Module): 
	def __init__(self): 
  	super(triplet_loss, self).__init__() 
    self.margin = 0.2
	def forward(self, anchor, positive, negative): 
  	pos_dist = (anchor - positive).pow(2).sum(1) 
    neg_dist = (anchor - negative).pow(2).sum(1) 
    loss = F.relu(pos_dist - neg_dist + self.margin) 
    return loss.mean()#we can also use #torch.nn.functional.pairwise_distance(anchor,positive, keep_dims=True), which #computes the euclidean distance.
  

"""
training part
"""
loss_fun = triplet_loss() 
optimizer = Adam(custom_model.parameters(), lr = 0.001) 
for epoch in range(30): 
    total_loss = 0 
    for i, (anchor, positive, negative) in enumerate(custom_loader): 
        anchor = anchor['image'].to(device) 
        positive = positive['image'].to(device) 
        negative = negative['image'].to(device) 
 
        anchor_feature = custom_model(anchor) 
        positive_feature = custom_model(positive) 
        negative_feature = custom_model(negative) 
 
        optimizer.zero_grad() 
        loss = loss_fun(anchor_feature, positive_feature, negative_feature) 
        loss.backward() 
        optimizer.step()
  

```

#### 参考链接

https://zhuanlan.zhihu.com/p/414327252?ivk_sa=1024320u
