# Python中一些语法的使用


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

