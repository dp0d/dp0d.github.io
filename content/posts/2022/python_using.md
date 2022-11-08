---
draft: false
title: "Python中一些语法的使用"
subtitle: ""
date: 2022-05-18T09:26:19+08:00
lastmod: 2022-05-18T09:26:19+08:00
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

## *args 和 **kwargs传参方法

### *args

元组传参

```python
def add(*args):
    print(args, type(args))

add(2, 3)
```

> ```
> (2, 3) <class 'tuple'>
> ```



```python
def add(*numbers):
    total = 0
    for num in numbers:
        total += num
    return total

print(add(2, 3))
print(add(2, 3, 5))
print(add(2, 3, 5, 7))
print(add(2, 3, 5, 7, 9))
```

> ```
> 5
> 10
> 17
> 26
> ```

### **kwargs

字典传参

```python
def total_fruits(**kwargs):
    print(kwargs, type(kwargs))


total_fruits(banana=5, mango=7, apple=8)
```

> ```
> {'banana': 5, 'mango': 7, 'apple': 8} <class 'dict'>
> ```



```python
def total_fruits(**fruits):
    total = 0
    for amount in fruits.values():
        total += amount
    return total


print(total_fruits(banana=5, mango=7, apple=8))
print(total_fruits(banana=5, mango=7, apple=8, oranges=10))
print(total_fruits(banana=5, mango=7))
```

> ```
> 20
> 30
> 12
> ```

## yeild返回方法

和return返回不同，yeild返回的是一个可迭代对象，可以通过next(yeild返回object)来取下一个元素

```python
def test_yield():
    for i in range(10):
        yield i


print(type(test_yield()))

_iter = test_yield()
print(next(_iter))
print(next(_iter))
print(next(_iter))
```

> ```
> <class 'generator'>
> 0
> 1
> 2
> ```

```python
def test_yield():
    for i in [3, 5, 6, 1, 3, 516, 6321, 1]:
        yield i


_iter = test_yield()
num = 0
try:
    while True:
        num += 1
        print(next(_iter))
except Exception as ex:
    pass

print("列表的元素个数%d" % num)
```

> ```
> 3
> 5
> 6
> 1
> 3
> 516
> 6321
> 1
> 列表的元素个数9
> ```

==问，为什么要这么干，直接len()不就好了吗？答，除了获取长度，还可以进行其他操作，而不用先获取列表长度进行。==

## 数据类型转换

### 列表内转换数据类型

```python
>>> # 返回一个迭代器
>>> var = map(str, [3, 1, 2])
>>> print(list(var))
>>> print(list(var))  # 迭代器走完就没有值了

>>> begin = time.time()  # 记录转换耗时
>>> # 返回一个列表(推荐使用，速度更快，因未出现显式循环)
>>> var_s = list(map(str, [3, 1, 2]))
>>> print(var_s, "转换耗时: ", time.time()-begin)

>>> begin = time.time()  # 记录转换耗时
>>> # 返回一个列表
>>> var_s = [str(i) for i in [3, 1, 2]]
>>> print(var_s, "转换耗时: ", time.time()-begin)

['3', '1', '2']
[]
['3', '1', '2'] 转换耗时:  1.430511474609375e-06
['3', '1', '2'] 转换耗时:  1.6689300537109375e-06
```

## 谨慎的赋值

python的执行中，等号右边先执行，如下代码中，python先创建出数组然后再让a指向该数组，如果简单用等号将a 赋值给b，则b也指向该数组，修改b的同时，原来的a也会随之改变，如果不想要a 发生改变，需使用b = a.copy()

```python
>>> # 第一种赋值方式
>>> a = [3, 1, 2]
>>> b = a
>>> b[0] = 0
>>> print(a, b)
>>> # 第二种赋值方式
>>> a = [3, 1, 2]
>>> b = a.copy()  # 复制法
>>> b[0] = 0
>>> print(a, b)
out:
[0, 1, 2] [0, 1, 2]
[3, 1, 2] [0, 1, 2]
```

## 漂亮的表格

单纯输出列表效果不好看，可以做成表格形式。

```python
>>> # 列表显示为表格
>>> from prettytable import PrettyTable
>>> fruit = [['apple', 'red', '100g'], ['banana', 'yellow', '80g']]
>>> print("直接打印列表\n", fruit)
>>> x = PrettyTable()  # 创建表格实例
>>> x.field_names = ['fruit', 'color', 'weight']  # 定义表头
>>> x.add_rows(fruit)
>>> print("打印成表格\n", x)
out:
直接打印列表
[['apple', 'red', '100g'], ['banana', 'yellow', '80g']]
打印成表格
 +--------+--------+--------+
| fruit  | color  | weight |
+--------+--------+--------+
| apple  |  red   |  100g  |
| banana | yellow |  80g   |
+--------+--------+--------+
```

## zip的妙用

```python
>>> a = [[1, 2],
     [3, 4],
     [5, 6]]
>>> print(*a)
>>> print(zip(*a))
>>> print(list(zip(*a)))
out:
[1, 2] [3, 4] [5, 6]
<zip object at 0x7fb6cd7e7f00>
[(1, 3, 5), (2, 4, 6)]
```



## 内置filter快速筛选出列表中的一类值

```python
>>> a = [3, 2, None, "", 0]
>>> # 剔除假值（python中,None、0、"" 都为假”）
>>> print(list(filter(bool, a)))

>>> # 剔除 3
>>> print(list(filter(lambda i: i != 3, a)))

# 筛选出奇数
b = [1, 2, 3, 4, 5]
print(list(filter(lambda i: i % 2, b)))

out:
[3, 2]
[2, None, '', 0]
[1, 3, 5]
```



## 查看变量占用的内存空间

```python
>>> import sys
>>> a = [3, 2, None, "", 0]
>>> b = 9
>>> c = "python"
>>> print("变量a占用的内存空间为{}字节，\n变量b占用的内存空间为{}字节，\n变量c占用内存空间为{}字        节。".format(
>>>     sys.getsizeof(a),
>>>     sys.getsizeof(b),
>>>     sys.getsizeof(c),
>>> ))

out:
变量a占用的内存空间为112字节，
变量b占用的内存空间为28字节，
变量c占用内存空间为55字节。
```

## 严格控制打印小数点后两位

```python
>>> print(f"{5/2:.2f}")
out:
2.50
```

