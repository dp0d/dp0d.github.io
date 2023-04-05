# Python中常见的文件读写




*说明*

**本文根据常见的读写进行方法阐述，本文实验环境基于python3.8，并需要提前告知各类读写方式的文件操作效果，如下列出：**

r :   读取文件，文件需要手动创建

w:   写入文件，若文件不存在则会自动创建再写入，会覆盖原文件

a :   写入文件，若文件不存在则会自动创建再写入，但不会覆盖原文件，而是追加在文件末尾

rb,wb：  分别于r, w类似，但是用于读写二进制文件，此类型可用于保存变量。

r+ :   可读、可写，文件需要手动创建，写操作时会覆盖原文件。

w+ :   可读，可写，文件不存在自动创建，会覆盖原文件。

a+ :  可读、可写，文件不存在自动创建，不会覆盖原文件，追加在末尾。

## csv格式文件
### csv库
#### 列表读写
```python
# 将以下两个列表作为两列写入CSV，用 ' ' 空格隔开：
import csv
list1=[1,2]
list2=['1','2']
with open('filename.csv', "w", newline='', encoding='utf-8') as f1:
    writer = csv.writer(f1, delimiter=',')
    writer.writerows(zip(list1,list2))
print('文件写入完成……')

# 作为两行呢
lis = [[1,2],['1','2']]
with open('filename.csv', "w", newline='', encoding='utf-8') as f1:
    writer = csv.writer(f1, delimiter=',')
    for data in lis:
        writer.writerow(data)
	
	
# 从上述写成的CSV中读出两个列表, 同样用 ' ' 空格隔开读取：
import csv
with open('filename.csv','r',encoding='utf-8') as f2:
    list1 = []
    list2 = []  # 这里注意，之前int类型的列表写入和读取之后都会变为str类型的列表
    reader = csv.reader(f2, delimiter = ',')
    for i in reader:
        list1.append(i[0])
        list2.append(i[1])
print('文件读取完成……')

# 其他模式
list = [[1,2,3],[4,5,6]]
with open('filename.csv', "w", newline='', encoding='utf-8') as f1:
    writer = csv.writer(f1, delimiter=',')
    writer.writerows(list)
print('文件写入完成……')
```
### pandas库
#### 读出多个文件并按列连接写入一个文件



```python

import pandas as pd

inputfile_csv_1='head-dep_context_1.csv'
inputfile_csv_2='head-dep_context_2.csv'
inputfile_csv_3='head-dep_context_3.csv'
inputfile_csv_4='head-dep_context_4.csv'
outputfile='4.csv'

csv_1 = pd.read_csv(inputfile_csv_1)
csv_2 = pd.read_csv(inputfile_csv_2)
csv_3 = pd.read_csv(inputfile_csv_3)
csv_4 = pd.read_csv(inputfile_csv_4)

out_csv=pd.concat([csv_1,csv_2,csv_3,csv_4],axis =1)
out_csv.to_csv(outputfile, index=False)
```

按列读入四个文件并按列合并：

## txt格式文件

	注：txt格式文件可以用于存放字典。
```python
# 向文件写入list1的字典vocab
list1 = ['3','1','1','2','2']
vocab = sorted(set(list))  # 创建一个list1的字典，由于set每次顺序会改变，为了保证程序能够复现，这里可以排序一下。
with open('filename.txt', 'w',encoding = 'utf-8') as f1:
    for i in vocab:
        f1.write(i + '\n')  # 这里向文件每行写入vocab的一个词作为字典
print('字典写入完成……')

        
# 从文件读取list1的字典vocab，逐行读取，一行一个词
vocab = []
with open('filename.txt', 'r', encoding = 'utf-8') as f2:
	lines = f2.readlines()
        for i in lines:
            vocab.append(i.strip('\n'))  # 去除每一行的换行符
print('字典读取完成……')
```

## pickle格式文件

	注：pickle可以将很多格式的数据保存到一个文件中以二进制保存。重新加载之后还是之前的格式。此种方式通常用于保存生成花销较大的中间变量，以提升工作效率。
```python
# 将var变量以二进制的形式写入文件,可以保存多种类型的变量：
import pickle
var = "I am your friend."
with open('filename.pickle', 'wb') as f1:
	pickle.dump(var, f1)
print('变量写入完成……')

# 从上述写成的pickle文件中以二进制读出var变量，变量类型读完后与保存时一致：
import pickle
with open('filename.pickle', 'rb') as f2:
	var = pickle.load(f2)
print('变量读取完成……')
```
## json格式文件

```python
# 写json文件，可以保存字典等类型的变量
import json
var_dic = {'1st':'你好','2nd':'世界'}
with open('filename.json', 'w') as f1:
    json.dump(var_dic,f1)
    
# 如果保存的是中文，默认会转为ascii码存储，如果想以中文存储，则需要指定
with open('filename_ch.json', 'w', encoding='utf-8') as f:
	json.dump(var_dic,f,ensure_ascii=False,indent = 4)

#读出json文件：
with open('filename.json', 'r') as f2:
    var_dic = json.dump(f2)
    
    
```

<script src="https://utteranc.es/client.js"
        repo="https://github.com/dp0d/dp0d.github.io.git"
        issue-term="title"
        label="Comment"
        theme="github-light"
        crossorigin="anonymous"
        async>
</script>
## mat格式文件

此种格式文件起初为matlab软件保存得到的，在python中也逐渐有了相关函数进行处理，其特点是可以压缩保存大矩阵文件，减小磁盘空间占用。

> 以下数据存取需要配套使用
>
> 大矩阵处理方式一

```python
import scipy.io as scio
import hdf5storage
# 存储你的数据字典，
def save(out_file_path: str,data: dict, do_compression: bool, large_array: bool):
    """
    :param out_file_path: 需要保存到的数据路径
    :param data: 你的数据字典
    :param do_compression: 是否压缩存储
    :return: 无
    """
    if not large_array:
    	scio.savemat(out_file_path, data, do_compression=do_compression)
    else:
			hdf5storage.savemat(out_file_path, data, do_compression=do_compression)
# 加载该数据
def save(file_path: str, large_array: bool):
  	if not large_array:
    	scio.loadmat(file_path)
    else:
    	hdf5storage.loadmat(file_pathn)
```

>  以下数据存取需要配套使用
>
> 大矩阵处理方式二

```python
import scipy.io as scio
from scipy.sparse import csc_matrix
# 存储你的数据字典，
def save(out_file_path: str,data: dict, do_compression: bool, large_array: bool):
    """
    :param out_file_path: 需要保存到的数据路径
    :param data: 你的数据字典
    :param do_compression: 是否压缩存储
    :return: 无
    """
    if not large_array:
    	scio.savemat(out_file_path, data, do_compression=do_compression)
    else:
      data['large_matrix_key'] = csc_matrix(data['large_matrix_key'])
			scio.savemat(out_file_path, data, do_compression=do_compression)
# 加载该数据
def save(file_path: str, large_array: bool):
  	if not large_array:
    	scio.loadmat(file_path)
    else:
    	scio.loadmat(file_path)
      data['large_matrix_key'] = data['large_matrix_key'].toarray()
```


