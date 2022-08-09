---
draft: false
title: "有关数据集调研和介绍"
subtitle: ""
date: 2022-08-09T16:43:36+08:00
lastmod: 2022-08-09T16:43:36+08:00
description: ""

tags: [] # env linux mac py tools win task
categories: [] # tutorial, technology_log, machine_learning, nlp
series: [] # python_data_analysis, jupyter, data_science_contest

toc:
  enable: true
math:
  enable: true
license: ""
---

| 任务                                               | 数据集                                                       | 描述                                                         | 语言                                                         |
| -------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 对话式问答(Conversational Question Answering, CQA) | [CoQA](https://aclanthology.org/Q19-1016)，[CuQA](https://aclanthology.org/D18-1241)等 | 基于给定文档的多轮问答，无需检索，短文。                     | 英文                                                         |
| CQA                                                | [OR-QuAC](https://doi.org/10.1145/3397271.3401110), [MultiDoc2Dial](https://aclanthology.org/2021.emnlp-main.498)等 | 基于多文档的多轮问答，需要检索，长文和多短文。               | 英文                                                         |
| CQA                                                | [INSCIT](https://arxiv.org/pdf/2207.00746v1.pdf)             | 面向信息检索的多轮多文档问答                                 | 英文                                                         |
| CQA                                                | [【CCL 2020】多轮对话问答数据采集平台](https://hub.baai.ac.cn/view/3190) | 未公开，已发邮件，长文，3000字以内，CCL2020                  | 中文                                                         |
| 机器阅读理解（Machine Reading Comprehension, MRC） | **[<br/>ChineseSquad](https://github.com/yuansky/ChineseSquad)** | 单轮机器阅读理解。                                           | 有一类做法是将数据集进行翻译为中文，本数据集便是从SQuAD翻译过来的中文数据集。 |
| MRC                                                | [CAIL大赛阅读理解数据集](http://cail.cipsc.org.cn/index.html),[DuReader](http://ai.baidu.com/broad/download?dataset=dureader) | 前者是最高人民法院司改办指导举办的中国法律智能技术评测大赛（每年都有，2021年有阅读理解任务），后者是百度在2018年机器阅读理解大赛上构造的数据集。 | 中文                                                         |
|                                                    |                                                              |                                                              |                                                              |



