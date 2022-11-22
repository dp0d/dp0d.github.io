---
draft: false
title: "Tensor的简单使用"
subtitle: ""
date: 2022-07-08T11:33:08+08:00
lastmod: 2022-07-08T11:33:08+08:00
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



# Tensor是什么？
Tensor又叫张量，与标量，向量等的区别如下：

1. 标量其实就是一个独立存在的数，比如在线性代数中一个实数 5 就可以被看作一个标量，所以标量的运算相对简单，与我们平常做的数字算术运算类似。

2) 向量就是一列数，这些数是有序排列的。用过次序中的索引，我们可以确定每个单独的数。我们可以将向量看做空间中的点，每个元素就是空间中的坐标。
3) 矩阵是二维数组，其中的每一个元素被两个索引而非一个所确定。我们通常会赋予矩阵粗体的大写变量名称。如果我们现在有N个用户的数据，每条数据含有M个特征，那其实它对应的就是一个N*M的矩阵
4) 几何代数中定义的张量是基于向量和矩阵的推广，通俗一点理解的话，我们可以将标量视为零阶张量，矢量视为一阶张量，那么矩阵就是二阶张量。 例如，可以将任意一张彩色图片表示成一个三阶张量，三个维度分别是图片的高度、宽度和色彩数据。

## Torch

### torch.argmax

返回最大值索引

> 返回所有值的最大值位置索引

```python
>>> a = torch.randn(4, 4)
>>> a
tensor([[ 1.3398,  0.2663, -0.2686,  0.2450],
        [-0.7401, -0.8805, -0.3402, -1.1936],
        [ 0.4907, -1.3948, -1.0691, -0.3132],
        [-1.6092,  0.5419, -0.2993,  0.3195]])
>>> torch.argmax(a)
tensor(0)
```

> 返回指定维度最大值的位置索引

```python
>>> a = torch.randn(4, 4)
>>> a
tensor([[ 1.3398,  0.2663, -0.2686,  0.2450],
        [-0.7401, -0.8805, -0.3402, -1.1936],
        [ 0.4907, -1.3948, -1.0691, -0.3132],
        [-1.6092,  0.5419, -0.2993,  0.3195]])
>>> torch.argmax(a, dim=1)
tensor([ 0,  2,  0,  1])

```

### torch.topk

返回特定维的top-k最大值的索引

```python
>>> x = torch.arange(1., 6.)
>>> x
tensor([ 1.,  2.,  3.,  4.,  5.])
>>> torch.topk(x, 3)
torch.return_types.topk(values=tensor([5., 4., 3.]), indices=tensor([4, 3, 2]))
```

top-k索引取得方式举例

```python
torch.topk(x, dim=1).indices.to('cpu').numpy()
```

### torch.cat

拼接tensor

```python
>>> x = torch.randn(2, 3)
>>> x
tensor([[ 0.6580, -1.0969, -0.4614],
        [-0.1034, -0.5790,  0.1497]])
>>> torch.cat((x, x, x), 0)
tensor([[ 0.6580, -1.0969, -0.4614],
        [-0.1034, -0.5790,  0.1497],
        [ 0.6580, -1.0969, -0.4614],
        [-0.1034, -0.5790,  0.1497],
        [ 0.6580, -1.0969, -0.4614],
        [-0.1034, -0.5790,  0.1497]])
>>> torch.cat((x, x, x), 1)
tensor([[ 0.6580, -1.0969, -0.4614,  0.6580, -1.0969, -0.4614,  0.6580,
         -1.0969, -0.4614],
        [-0.1034, -0.5790,  0.1497, -0.1034, -0.5790,  0.1497, -0.1034,
         -0.5790,  0.1497]])
```

### torch.stack

将一个tensor序列组合Concatenates为一个新的tensor，所有的tensor需要是相同的size（shape）

```python
>>> tensor_lis = []
>>> for i in range(4):
...     x = torch.randn(3,)
...     tensor_lis.append(x)
... 
>>> tensor_lis
[tensor([ 0.4239, -0.4117, -1.4423]), tensor([ 0.0388,  0.2642, -0.0006]), tensor([-0.4351,  0.4171, -1.1180]), tensor([ 0.2685,  0.6888, -1.6707])]

>>> a = torch.stack(tensor_lis,dim=0)
>>> a
tensor([[ 4.2391e-01, -4.1169e-01, -1.4423e+00],
        [ 3.8823e-02,  2.6416e-01, -6.1708e-04],
        [-4.3513e-01,  4.1708e-01, -1.1180e+00],
        [ 2.6853e-01,  6.8878e-01, -1.6707e+00]])

```

### torch.squeeze 

squeeze是英文   挤     的意思

返回一个张量，其中所有`input`大小为1的维度都已删除。

例如，如果输入是形状： $(A \times 1 \times B \times C \times 1 \times D)$那么输出张量将具有以下形状：（$A \times B \times C\times D$）.

`dim`给定时，仅在给定维度上进行挤压操作。如果输入是形状：$(A \times 1 \times B)$，squeeze(input, 0) 语句将保持张量不变，但squeeze(input, 1)语句会将张量压缩到形状$(A \times B)$.

```python
>>> x = torch.zeros(2, 1, 2, 1, 2)
>>> x.size()
torch.Size([2, 1, 2, 1, 2])
>>> y = torch.squeeze(x)
>>> y.size()
torch.Size([2, 2, 2])
>>> y = torch.squeeze(x, 0)
>>> y.size()
torch.Size([2, 1, 2, 1, 2])
>>> y = torch.squeeze(x, 1)
>>> y.size()
torch.Size([2, 2, 1, 2])
```

### torch.tensor.view

改变tensor的形状，注意，调用的时候是作用在tensor上的，比如tensor_x.view()，而不是torch.view()，有所区别。

```python
>>> x = torch.randn(4, 4)
>>> x.size()
torch.Size([4, 4])
>>> y = x.view(16)
>>> y.size()
torch.Size([16])
>>> z = x.view(-1, 8)  # the size -1 is inferred from other dimensions
>>> z.size()
torch.Size([2, 8])

>>> a = torch.randn(1, 2, 3, 4)
>>> a.size()
torch.Size([1, 2, 3, 4])
>>> b = a.transpose(1, 2)  # Swaps 2nd and 3rd dimension
>>> b.size()
torch.Size([1, 3, 2, 4])
>>> c = a.view(1, 3, 2, 4)  # Does not change tensor layout in memory
>>> c.size()
torch.Size([1, 3, 2, 4])
>>> torch.equal(b, c)
False
```

改变数据类型，通常用于控制浮点数

```python
>>> x = torch.randn(4, 4)
>>> x
tensor([[ 0.9482, -0.0310,  1.4999, -0.5316],
        [-0.1520,  0.7472,  0.5617, -0.8649],
        [-2.4724, -0.0334, -0.2976, -0.8499],
        [-0.2109,  1.9913, -0.9607, -0.6123]])
>>> x.dtype
torch.float32

>>> y = x.view(torch.int32)
>>> y
tensor([[ 1064483442, -1124191867,  1069546515, -1089989247],
        [-1105482831,  1061112040,  1057999968, -1084397505],
        [-1071760287, -1123489973, -1097310419, -1084649136],
        [-1101533110,  1073668768, -1082790149, -1088634448]],
    dtype=torch.int32)
>>> y[0, 0] = 1000000000
>>> x
tensor([[ 0.0047, -0.0310,  1.4999, -0.5316],
        [-0.1520,  0.7472,  0.5617, -0.8649],
        [-2.4724, -0.0334, -0.2976, -0.8499],
        [-0.2109,  1.9913, -0.9607, -0.6123]])

>>> x.view(torch.cfloat)
tensor([[ 0.0047-0.0310j,  1.4999-0.5316j],
        [-0.1520+0.7472j,  0.5617-0.8649j],
        [-2.4724-0.0334j, -0.2976-0.8499j],
        [-0.2109+1.9913j, -0.9607-0.6123j]])
>>> x.view(torch.cfloat).size()
torch.Size([4, 2])

>>> x.view(torch.uint8)
tensor([[  0, 202, 154,  59, 182, 243, 253, 188, 185, 252, 191,  63, 240,  22,
           8, 191],
        [227, 165,  27, 190, 128,  72,  63,  63, 146, 203,  15,  63,  22, 106,
          93, 191],
        [205,  59,  30, 192, 112, 206,   8, 189,   7,  95, 152, 190,  12, 147,
          89, 191],
        [ 43, 246,  87, 190, 235, 226, 254,  63, 111, 240, 117, 191, 177, 191,
          28, 191]], dtype=torch.uint8)
>>> x.view(torch.uint8).size()
torch.Size([4, 16])
```

### Tensor归一化操作

> 按行（样本）归一化(前提是输出大于零)

```python
>>> import torch
>>> import torch.nn.functional as F
>>> import numpy as np

>>> arr = np.array([[1, 1, 0, 0, 0, 0, 0], [0, 1, 0, 0, 0, 0, 1]])
>>> print(F.normalize(torch.tensor(arr).float(), p=1, dim=1))


```

### Tensor的多条件选取

```python
>>> a = [1., 2., 3, 4]
>>> b = [-1., -2., -3., -4.]
>>> a_tensor = torch.as_tensor(a, dtype=torch.float)
>>> b_tensor = torch.as_tensor(b, dtype=torch.float)

>>> # 单条件选取
>>> print(a_tensor[a_tensor > 1.])
tensor([2., 3., 4.])

>>> # 多条件选取
>>> condition1 = torch.where((a_tensor > 1.) & (a_tensor < 4.))
>>> condition2 = torch.where((a_tensor == 1.) | (a_tensor == 4.))
>>> print(a_tensor[condition1])
tensor([2., 3.])
>>> # 反条件选取
>>> condition = torch.where((a_tensor > 1.) & (a_tensor < 4.), True, False) # 首先转为bool类型
>>> print(a_tensor[~condition])    # 然后取反
tensor([1., 4.])

>>> print(a_tensor[condition2])
tensor([1., 4.])

>>> # 条件选另一个tensor里的值(a,b等维)
>>> print(b_tensor[condition1])
tensor([-2., -3.])
```

### 不同形状的Tensor之间计算

```python
>>> a = [[1., 2., 3, 4],
        [1., 2., 3, 4]]
>>> b = [[[-1., -2., -3., -4.],
          [-1., -2., -3., -4.],
          [-1., -2., -3., -4.]],
         [[-1., -2., -3., -4.],
          [-1., -2., -3., -4.],
          [-1., -2., -3., -4.]]]
>>> a_tensor = torch.as_tensor(a, dtype=torch.float)      # shape torch.size([2,4])
>>> b_tensor = torch.as_tensor(b, dtype=torch.float)      # shape torch.size([2,3,4])
>>> a_tensor = a_tensor.unsqueeze(1)                      # 扩展一个id=1的维度
>>> print(a_tensor)
tensor([[[1., 2., 3., 4.]],
        [[1., 2., 3., 4.]]])

>>> print(a_tensor-b_tensor)
tensor([[[2., 4., 6., 8.],
         [2., 4., 6., 8.],
         [2., 4., 6., 8.]],
        [[2., 4., 6., 8.],
         [2., 4., 6., 8.],
         [2., 4., 6., 8.]]])
         
>>> print((a_tensor-b_tensor)**2)
tensor([[[ 4., 16., 36., 64.],
         [ 4., 16., 36., 64.],
         [ 4., 16., 36., 64.]],
        [[ 4., 16., 36., 64.],
         [ 4., 16., 36., 64.],
         [ 4., 16., 36., 64.]]])

# 二范式，dim2维度的所有值平方，求和，然后开根号
>>> print(torch.norm(a_tensor-b_tensor, p=2, dim=2))
tensor([[10.9545, 
         10.9545, 
         10.9545],
        [10.9545, 
         10.9545, 
         10.9545]])

# 二范式，dim2维度的所有值平方，求和，然后开根号，和上面结果一致
>>> print(torch.linalg.norm(a_tensor-b_tensor, dim=2))
tensor([[10.9545, 10.9545, 10.9545],
        [10.9545, 10.9545, 10.9545]])
```

