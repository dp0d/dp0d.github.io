---
draft: true
title: "好用的Python基础算法应用技巧"
subtitle: "将日常使用的python技巧记录下来"
date: 2022-04-26T19:17:07+08:00
lastmod: 2022-04-26T19:17:07+08:00
description: ""

tags: [py] # env linux mac py tools win
categories: [] # tutorial
series: []

toc:
  enable: true
math:
  enable: true
license: ""
---

## 排序

### 列表

#### 内置排序方法

> **sort()**

```python
lis = [4,2,3,1]
lis.sort()
print(lis)
```

[1, 2, 3, 4]

> **sorted()**

```python
lis = [4,2,3,1]
sorted(lis)
print(lis)
lis = sorted(lis)
print(lis)
lis.reverse()
print(lis)
```

[4, 2, 3, 1]

[1, 2, 3, 4]

[4, 3, 2, 1]

##### 带原索引一起排序

这种方法的好处是，如果你有两个列表，一一对应，你想在变化其中一个的时候希望另一个跟着变动相同的索引，你便需要用到。

```pyt
lis_a = [4,2,3,1]
lis_b = [3,4,1,2]

new_lis_a = []
new_lis_b = []
c = sorted(enumerate(lis_a),key = lambda x:x[1]) # x[1] 根据元组的第二个元素排序

for i in range(len(c)):
    new_lis_a.append(c[i][1])
    new_lis_b.append(lis_b[c[i][0]]) 
print(new_lis_a)
print(new_lis_b)
```

[1, 2, 3, 4]

[2, 4, 1, 3]

发现了前面两个列表对应的位置都是一样的元素了么？easy 
