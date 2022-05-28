---
draft: false
title: "Pandas的使用方法"
subtitle: ""
date: 2022-05-23T15:39:35+08:00
lastmod: 2022-05-23T15:39:35+08:00
description: ""

tags: [tools, py] # env linux mac py tools win task
categories: [] # tutorial, technology_log, machine_learning, nlp
series: [python_data_analysis]

toc:
  enable: true
math:
  enable: true
license: ""
---

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

### Dataframe形状处理

#### 打印开头几行数据

```python
df.head()
```

```python
import pandas as pd
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
      <th>1</th>
      <td>7b9652b17b68b7a4</td>
      <td>abatement</td>
      <td>act of abating</td>
      <td>A47</td>
      <td>0.75</td>
    </tr>
    <tr>
      <th>2</th>
      <td>36d72442aefd8232</td>
      <td>abatement</td>
      <td>active catalyst</td>
      <td>A47</td>
      <td>0.25</td>
    </tr>
    <tr>
      <th>3</th>
      <td>5296b0c19e1ce60e</td>
      <td>abatement</td>
      <td>eliminating process</td>
      <td>A47</td>
      <td>0.50</td>
    </tr>
    <tr>
      <th>4</th>
      <td>54c1e3b9184cb5b6</td>
      <td>abatement</td>
      <td>forest region</td>
      <td>A47</td>
      <td>0.00</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
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
      <th>1</th>
      <td>A01</td>
      <td>AGRICULTURE; FORESTRY; ANIMAL HUSBANDRY; HUNTI...</td>
      <td>A</td>
      <td>1.0</td>
      <td>NaN</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>2</th>
      <td>A01B</td>
      <td>SOIL WORKING IN AGRICULTURE OR FORESTRY; PARTS...</td>
      <td>A</td>
      <td>1.0</td>
      <td>B</td>
      <td>NaN</td>
      <td>NaN</td>
    </tr>
    <tr>
      <th>3</th>
      <td>A01B1/00</td>
      <td>Hand tools (edge trimmers for lawns A01G3/06  ...</td>
      <td>A</td>
      <td>1.0</td>
      <td>B</td>
      <td>1.0</td>
      <td>0.0</td>
    </tr>
    <tr>
      <th>4</th>
      <td>A01B1/02</td>
      <td>Spades; Shovels {(hand-operated dredgers E02F3...</td>
      <td>A</td>
      <td>1.0</td>
      <td>B</td>
      <td>1.0</td>
      <td>2.0</td>
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
|    1 | 7b9652b17b68b7a4 | abatement |     act of abating     |   A47   | 0.75  | FURNITURE; DOMESTIC ARTICLES OR APPLIANCES; CO... |
|    2 | 36d72442aefd8232 | abatement |    active catalyst     |   A47   | 0.25  | FURNITURE; DOMESTIC ARTICLES OR APPLIANCES; CO... |
|    3 | 5296b0c19e1ce60e | abatement |  eliminating process   |   A47   | 0.50  | FURNITURE; DOMESTIC ARTICLES OR APPLIANCES; CO... |
|    4 | 54c1e3b9184cb5b6 | abatement |     forest region      |   A47   | 0.00  | FURNITURE; DOMESTIC ARTICLES OR APPLIANCES; CO... |
|  ... |       ...        |    ...    |          ...           |   ...   |  ...  |                        ...                        |



### Dataframe数据处理

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

