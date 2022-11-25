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

### 距离度量

#### F 范数（Frobenius 范数）

矩阵所有元素的平方和再开方，他是是向量二范式的拓展类比。

{{< math >}}
$$
||A||_F = \sqrt{\sum a_{ij}^2}
$$
{{< /math >}}

如何作为距离度量呢？

可以利用如下方式，如果标签矩阵为$B$（通常为一个batch里的多个样本标签向量组成，如标签向量为4维，batch_size 为128）则$B$的形状为（128，4）），距离度量公式为
$$
\mathcal L_F = ||A-B||
$$

#### 核范数（nuclear norm）

作为距离度量方式不详
$$
\begin{aligned}
||A||_*=\operatorname{tr}\left(\sqrt{A^{T} A}\right) &=\operatorname{tr}\left(\sqrt{\left(U \Sigma V^{T}\right)^{T} U \Sigma V^{T}}\right) \\
&=\operatorname{tr}\left(\sqrt{V \Sigma^{T} U^{T} U \Sigma V^{T}}\right) \\
&=\operatorname{tr}\left(\sqrt{V \Sigma^{2} V^{T}}\right)\left(\Sigma^{T}=\Sigma\right) \\
&=\operatorname{tr}\left(\sqrt{V^{T} V \Sigma^{2}}\right) \\
&=\operatorname{tr}(\Sigma)
\end{aligned}
$$

> 参考代码

```python
import torch
label = np.array([[1, 2, 3, 4], [1, 2, 3, 4]])
pred = np.array([[2, 3, 4, 5], [2, 3, 4, 5]])

print("F范数矩阵")
print(torch.norm(torch.from_numpy(pred - label).type(torch.cuda.FloatTensor), p="fro", dim=-1))
print("2范数矩阵")
print(torch.norm(torch.from_numpy(pred - label).type(torch.cuda.FloatTensor), p=2, dim=-1))

print("核范数矩阵")  # 核范数作为Loss使用方法不详
print(torch.norm(torch.from_numpy(pred - label).type(torch.cuda.FloatTensor), p="nuc"))

print("平均损失计算：每个样本的损失相加，再除以总样本数")
print(torch.norm(torch.from_numpy(pred - label).type(torch.cuda.FloatTensor), p="fro", dim=-1).sum() / label.shape[0])
print(torch.norm(torch.from_numpy(pred - label).type(torch.cuda.FloatTensor), p=2, dim=-1).sum() / label.shape[0])

输出：
F范数矩阵
tensor([2., 2.], device='cuda:0')
2范数矩阵
tensor([2., 2.], device='cuda:0')
核范数矩阵
tensor(2.8284, device='cuda:0')
平均损失计算：每个样本的损失相加，再除以总样本数
tensor(2., device='cuda:0')
tensor(2., device='cuda:0')

Process finished with exit code 0

```

```python
>>> # 不同shape的欧距计算 作者：https://blog.csdn.net/sinat_24899403/article/details/119249822
>>> import torch
>>> from torch import nn

>>> a=torch.tensor([[1,1,1],
                [2,2,2]])
>>> b=torch.tensor([[2,2,2],
								[1,1,1],
                [2,2,2],
                [1,1,1],
                [2,2,2]])
>>> def pdist(a: torch.Tensor, b: torch.Tensor, p: int = 2) -> torch.Tensor:
    return (a-b).abs().pow(p).sum(-1).pow(1/p)

>>> a_=a.unsqueeze(1)
>>> b_=b.unsqueeze(0)
>>> print(pdist(a_,b_))

tensor([[1.7321, 0.0000, 1.7321, 0.0000, 1.7321],
        [0.0000, 1.7321, 0.0000, 1.7321, 0.0000]])

```



#### 汉明距离

> 如果是多对多，且shape不一致，使用numpy计算是最快的，考虑原因可能是torch未封装int类型的不同shape数据的计算方式，如果shape相同可以使用pairwise的方法

形状相同（用于标签预测）

```python
>>> b = torch.tensor([[0, 0, 1],
                  [0, 1, 0]
                  ])
>>> c = torch.tensor([[1, 0, 1],
                  [0, 1, 0]
                  ])
>>> metric = BinaryHammingDistance(multidim_average='samplewise')
>>> print(metric(b, c))
tensor([0.3333, 0.0000])
```

形状不同（用于检索）

```python

>>> from sklearn.neighbors import DistanceMetric
>>> import time
>>> a = np.array([[0, 0, 2],])
>>> b = np.array([[0, 0, 1],
              [0, 1, 0]
              ])
>>> s1 = time.time()
>>> print(DistanceMetric.get_metric("hamming").pairwise(a,b))
>>> print(f"耗时{time.time()-s1}")
[[0.33333333 0.66666667]]
耗时0.0003008842468261719

>>> a_tensor = torch.as_tensor(a, dtype=torch.float)
>>> b_tensor = torch.as_tensor(b, dtype=torch.float)
>>> s2 = time.time()
>>> print(torch.cdist(a_tensor, b_tensor, p=0))
>>> print(f"耗时{time.time()-s2}")
tensor([[1., 2.]])
耗时0.0003383159637451172

>>> a_tensor = torch.as_tensor(a, dtype=torch.float).cuda()
>>> b_tensor = torch.as_tensor(b, dtype=torch.float).cuda()
>>> s3 = time.time()
>>> print(torch.cdist(a_tensor, b_tensor, p=0))
>>> print(f"耗时{time.time()-s3}")
tensor([[1., 2.]], device='cuda:0')
耗时0.0015494823455810547
```



### 相对熵（也称KL散度）

[**维基百科**](https://zh.wikipedia.org/wiki/%E7%9B%B8%E5%AF%B9%E7%86%B5)：KL散度（Kullback-Leibler divergence，简称KLD），在讯息系统中称为相对熵（relative entropy），在连续时间序列中称为随机性（randomness），在统计模型推断中称为讯息增益（information gain）。也称讯息散度（information divergence）。它是两个几率分布$P$和$Q$差别的非对称性的度量。 KL散度是用来度量使用基于$Q$的分布来编码服从$P$的分布的样本所需的额外的平均比特数，注意$P$,$Q$先后顺序。典型情况下，P表示数据的真实分布，Q表示数据的理论分布、估计的模型分布、或P的近似分布。

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
\begin{equation}
\mathcal L = -\frac{1}{N}\sum_{i=1}^N\sum_{j=1}^ny_j^{(i)}\cdot \log\hat{y}_j^{(i)}
\end{equation}
$$

其中,$n$为分类个数，即标签向量维度。$N$为样本个数。

### 对比损失

#### 三元损失

{{< math >}}

给定anchor $p$，以欧距为例，衡量相似度，其正样本为$q$，负样本为$r$。

$$
\begin{equation}
\begin{aligned}
\mathcal L = max(||\boldsymbol p-\boldsymbol q||^2-||\boldsymbol p-\boldsymbol r||^2+\epsilon,0)
\end{aligned}
\end{equation}
$$
{{< /math >}}



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

更多对比损失  https://lilianweng.github.io/posts/2021-05-31-contrastive/
