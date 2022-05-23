---
draft: true
title: "自然语言处理相关任务与数据集"
subtitle: ""
date: 2022-05-23T14:18:25+08:00
lastmod: 2022-05-23T14:18:25+08:00
description: ""

tags: [task] # env linux mac py tools win task
categories: [nlp] # tutorial, technology_log, machine_learning, nlp
series: []

toc:
  enable: true
math:
  enable: true
license: ""
---

|           Task            | Description                                                  |                             link                             |
| :-----------------------: | ------------------------------------------------------------ | :----------------------------------------------------------: |
|           SNLI            | Stanford language inference task. <br/>斯坦福大学语言推理任务。给定一个前提和一个假设，目标是预测假设与前提的关系是包含的、中性的，还是矛盾的。 |                                                              |
|           MNLI            | Language inference dataset on multigenre texts.<br/>多类型文本的语言推断数据集，包括转录语音、流行小说和政府报告(Wilmams等人，2018)，句子对，一个前提，一个是假设。前提和假设的关系有三种情况：蕴含（entailment），矛盾（contradiction），中立（neutral）。句子对三分类问题。与SNLI数据集相比，不同的写作和口语风格文本更为复杂，包括与训练域匹配的验证数据和与训练域不匹配的验证数据（一个是matched(m)，另一个是mismatched（mm）即训练和验证不在同一个数据集上进行比如语音和小说等）。<br/> |                                                              |
|    Yelp(Yelp Polarity)    | Document-level sentiment classification on positive and negative reviews. |                                                              |
|           IMDB            | Document-level sentiment classification dataset on positive and negative movie reviews, where the average sequence length is longer than the Yelp dataset.<br/>篇章级别的影评，判断评论为正向或者负向。 |    [Click here to download](https://datasets.imdbws.com/)    |
|       AG(AG’s News)       | Setence-level classification with regard to four news topics: World, Sports, Business, and Science/Technology. | [Click here to download(Kaggle)](https://www.kaggle.com/amananandrai/ag-news-classification-dataset) |
| Fake(Fake News Detection) | Document-level classification on whether a news article is fake or not. The dataset<br/>comes from the Kaggle Fake News Challenge | [Click here to download(Kaggle)](https://www.kaggle.com/c/fake-news/data) |

