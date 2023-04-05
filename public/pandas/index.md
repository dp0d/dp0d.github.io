# Pandas的使用方法


## Pandas

```python
import pandas as pd
```

### 数据读取

+ csv格式

有表头模式

```python
df = pd.read_csv('file')
```

无表头模式

```python
df = pd.read_csv('file', header=None)
```

读取之后为各列取表头（列名）

```python
df = pd.read_csv('data/dataset/raw_data/data.csv', header=None)
df.columns = ['label_text', 'chapter', 'section', 'subsection', 'text']
```



### 形状处理

#### 打印开头几行数据

```python
df.head()
```

```python
input_path = 'data/contest_data/' #input need be adjusted
df = pd.read_csv(input_path+'train.csv')
df_title = pd.read_csv(input_path+'titles.csv')
```

#### 去除空值数据行

```python
df = df.dropna()
```

#### 根据特定列数据特征删除数据行

例如，删除unit列值为'参考价'的行

```python
df = df.drop(df[df['unit']=='参考价'].index)
```



#### 合并两个Dataframe

第一个df


```python
df
```

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>id</th>
      <th>anchor</th>
      <th>target</th>
      <th>context</th>
      <th>score</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>37d61fd2272659b1</td>
      <td>abatement</td>
      <td>abatement of pollution</td>
      <td>A47</td>
      <td>0.50</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
		</tr>
   </tbody>
</table>

第二个df


```python
df_title
```

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>code</th>
      <th>title</th>
      <th>section</th>
      <th>class</th>
      <th>subclass</th>
      <th>group</th>
      <th>main_group</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>0</th>
      <td>A</td>
      <td>HUMAN NECESSITIES</td>
      <td>A</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
  </tbody>
</table>


将它们分别按照context列内容和code列内容对应相等进行拼接，df在左，dftitle（code值唯一）可重复使用，相当于查表。


```python
df = df.merge(df_title, how='left', left_on='context', right_on='code')
df = df[['id', 'anchor', 'target', 'context', 'score', 'title']]
```

拼接完成

```python
df
```

|      |        id        |  anchor   |         target         | context | score |                       title                       |
| ---: | :--------------: | :-------: | :--------------------: | :-----: | :---: | :-----------------------------------------------: |
|    0 | 37d61fd2272659b1 | abatement | abatement of pollution |   A47   | 0.50  | FURNITURE; DOMESTIC ARTICLES OR APPLIANCES; CO... |
|  ... |       ...        |    ...    |          ...           |   ...   |  ...  |                        ...                        |



### 数据处理

#### 隐函数方法

举个最简单的例子，total里都是899万元的形式，把万元替换掉，并转为float格式，其实隐函数干的远不止这些……

```python
format_fun = lambda x: float(x.replace('万元', ''))
df["price"] = df["total"].apply(format_fun)
```



#### 合并两列字符串

```python
df["Full Name"] = df["province"].map(str) +','+ df["city"]
city_lis = list(set(list(df['Full Name'].values)))
print(city_lis[:3])
```

>```
>['山东,青岛', '江西,赣州', '甘肃,兰州']
>```

相同功能

```python
df["Full Name"] = df["First"] + " " + df["Last"]

df['Full Name'] = df[['First', 'Last']].apply(' '.join, axis=1)

df['Full Name'] = df['First'].str.cat(df['Last'],sep=" ")

df['Full Name'] = df[['First', 'Last']].agg(' '.join, axis=1)
```

#### 列间数据计算

举个例子，通过总价和面积得到单价列

```python
df["total_price"] = df["total"].apply(lambda x: float(x.replace('万元', '')))

df['area_num'] = df["area"].apply(lambda x: float(x.replace('㎡', '')))

df['unit_pice'] = df['total_price'].map(float) / df['area_num'] * 10000
```

#### 分组数据计算

##### 计算均值

举例，按列Full Name 分组，计算各组的unit_price均值

```python
df.groupby('Full Name')['unit_pice'].mean()
```

#### 数据转换

强转就好了dict(),int(),float()……

```python
dic = dict(df.groupby('Full Name')['unit_pice'].mean())
```

转化为numpy.ndarray

array

```
array = df['text'].values

array = df['text'].values.astype(str)

```

#### loc方法

如果不存在fold列，新建'fold'列，并在位置[0, 5]上赋值为1。

```python
import pandas as pd
df = pd.DataFrame({"featrues": ["long", "high", "long", "short", "big", "small"], "labels": ["1", "1", "1", "0", "1", "0"]})
df.loc[[0, 5], 'fold'] = 1
df
```

> ```
> 	featrues	labels	fold
> 0	long	1	1.0
> 1	high	1	NaN
> 2	long	1	NaN
> 3	short	0	NaN
> 4	big	1	NaN
> ```



### 打印属性

#### 显示所有行和列

```python
#显示所有列
pd.set_option('display.max_columns', None)

#显示所有行
pd.set_option('display.max_rows', None)

#设置value的显示长度为100，默认为50
pd.set_option('max_colwidth',100)
```

### 采样方法

#### 随机采样

```python
# 随机采样100个
>>> df_sampled = df.sample(n=100)

# 随机采样50%的样本
>>> df_sampled = df.sample(frac=0.5)

```

#### 条件采样

```python
# 选苹果的行
>>> df_sampled = df[df['fruit'] == 'apple']
```

#### 分组采样

```python
>>> df = pd.DataFrame(
...     {"a": ["red"] * 2 + ["blue"] * 2 + ["black"] * 2, "b": range(6)}
... )
>>> df
       a  b
0    red  0
1    red  1
2   blue  2
3   blue  3
4  black  4
5  black  5

# 每组里头采样一个数据
>>> df.groupby("a").sample(n=1, random_state=1)
       a  b
4  black  4
2   blue  2
1    red  1

# 按列"a"的值分组采样，只保留列"b"的值
>>> df.groupby("a")["b"].sample(frac=0.5, random_state=2)
5    5
2    2
0    0
Name: b, dtype: int64

# 为每个样本赋予采样权重
>>> df.groupby("a").sample(
...     n=1,
...     weights=[1, 1, 1, 0, 0, 1],
...     random_state=1,
... )
       a  b
5  black  5
2   blue  2
0    red  0

```

### 获取索引

> 按照条件取特定行的索引 pandas 1.5.2

```python
fruit = ["apple", "peach", "peach", "watermelon"]
>>> df = pd.DataFrame({
...    "fruit": fruit
...    })
>>> idx = df.index[df["fruit"]=="peach"]
>>> print(id)
Int64Index([1, 2], dtype='int64')
>>> print(idx.tolist())
[1, 2]
```

### 索引取值

> 根据pandas索引类型或list类型的索引取值，可以多个 pandas 1.5.2

```python
fruit = ["apple", "peach", "peach", "watermelon"]
>>> df = pd.DataFrame({
...    "fruit": fruit
...    })
>>> idx = df.index[df["fruit"]=="peach"]
>>> print(df.loc[idx])
   fruit
1  peach
2  peach
>>> print(df.loc[idx.tolist()])
   fruit
1  peach
2  peach
```


