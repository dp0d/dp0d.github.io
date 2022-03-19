---
title: "反向传播算法"
date: 2022-03-18T11:29:42+08:00
math: true
draft: false
---

# 反向传播算法

作为一位机器学习领域的博主，第一篇博客肯定要从反向传播算法开始啦~

## 简介

​	来自[维基百科](https://zh.wikipedia.org/wiki/%E5%8F%8D%E5%90%91%E4%BC%A0%E6%92%AD%E7%AE%97%E6%B3%95#cite_note-Alpaydin2010-10)

​	首先是反向传播算法的历史沿用↓

​	[弗拉基米尔·瓦普尼克](https://zh.wikipedia.org/wiki/弗拉基米尔·瓦普尼克)引用（Bryson, A.E.; W.F. Denham; S.E. Dreyfus. Optimal programming problems with inequality constraints. I: Necessary conditions for extremal solutions. AIAA J. 1, 11 (1963) 2544-2550）在他的书《支持向量机》中首次发表反向传播算法。在1969年[Arthur E. Bryson](https://zh.wikipedia.org/w/index.php?title=Arthur_E._Bryson&action=edit&redlink=1)和[何毓琦](https://zh.wikipedia.org/wiki/何毓琦)将其描述为多级动态系统优化方法。直到1974年以后在神经网络的背景下应用，并由[Paul Werbos](https://zh.wikipedia.org/w/index.php?title=Paul_Werbos&action=edit&redlink=1)[[7\]](https://zh.wikipedia.org/wiki/反向传播算法#cite_note-9)、[David E. Rumelhart](https://zh.wikipedia.org/w/index.php?title=David_E._Rumelhart&action=edit&redlink=1)、[杰弗里·辛顿](https://zh.wikipedia.org/wiki/杰弗里·辛顿)和[Ronald J. Williams](https://zh.wikipedia.org/w/index.php?title=Ronald_J._Williams&action=edit&redlink=1)[[1\]](https://zh.wikipedia.org/wiki/反向传播算法#cite_note-Rumelhart1986-1)[[8\]](https://zh.wikipedia.org/wiki/反向传播算法#cite_note-Alpaydin2010-10)的著作，它才获得认可，并引发了一场人工神经网络的研究领域的“文艺复兴”。在21世纪初人们对其失去兴趣，但在2010年后又拥有了兴趣，如今可以通过[GPU](https://zh.wikipedia.org/wiki/圖形處理器)等大型现代运算器件用于训练更大的网络。例如在2013年，顶级语音识别器现在使用反向传播算法训练神经网络。

​	那么反向传播算法是啥？↓

​	**反向传播**（英语：Backpropagation，缩写为**BP**）是“误差反向传播”的简称，是一种与[最优化方法](https://zh.wikipedia.org/wiki/最优化)（如[梯度下降法](https://zh.wikipedia.org/wiki/梯度下降法)）结合使用的，用来训练[人工神经网络](https://zh.wikipedia.org/wiki/人工神经网络)的常见方法。该方法对网络中所有权重计算[损失函数](https://zh.wikipedia.org/wiki/损失函数)的梯度。这个梯度会回馈给最佳化方法，用来更新权值以最小化损失函数。
$A$

## 推导

### a. 了解矩阵乘法

假设


$$
\textbf{A} = 

\begin{bmatrix}
1 & 2 \\
3 & 4 \\
\end{bmatrix}

,
\textbf{B}=\left[
    \begin{matrix}
	-1 & -2 \\
	-3 & -4 \\
    \end{matrix}
\right]
$$




**点积**（通常省略  ·   符号）计算如下

$$
\textbf{AB} =
\left[
	\begin{matrix}
	1 \times(-1) + 2\times(-3) & 1\times (-2) +2\times(-4)\\
	3 \times(-1) + 4\times(-3) & 3\times(-2) +4 \times(-4)
	\end{matrix}
\right]=
\left[
	\begin{matrix}
	-7 & -10\\
	-15& -22
	\end{matrix}
\right]
$$


**逐元素乘法**如下

$$
\textbf{A}\odot\textbf{B} =
\left[
	\begin{matrix}
	1 \times(-1)& 2\times(-2)\\
	3 \times(-3)& 4 \times(-4)
	\end{matrix}
\right]=
\left[
	\begin{matrix}
	-1 & -4\\
	-9& -16
	\end{matrix}
\right]
$$


### b.了解神经网络

如下图所示，这是一个神经网络

![Sample_Neural_Network](Sample_Neural_Network.png)

可以看到，这个神经网络的隐藏层（除了第一层输入层和最后一层输出层之外都是隐藏层）与所有上一层的神经元都连接了，我们一般称这样的层为全连接层。可以看到，图中的神经网络较为复杂，接下来，我们先看看最基本的神经元是什么样的。











