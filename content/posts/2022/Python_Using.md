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
