---
draft: false
title: "正则表达式"
subtitle: ""
date: 2022-05-13T19:33:58+08:00
lastmod: 2022-05-13T19:33:58+08:00
description: ""

tags: [] # env linux mac py tools win
categories: [] # tutorial
series: []

toc:
  enable: true
math:
  enable: true
license: ""
---

## re用法示例

```python
# 过多换行替换为'￥￥￥中English$$$'
sub_text = re.sub(r'\n{2,}','￥￥￥中English$$$',sub_text)
# 找到 chapter_con 中的section_pattern_extra模式串
_section_title = re.findall(section_pattern_extra,chapter_con)
```



## 通过开头结尾匹配

```
# (?=〈更).*?(?=\\)   匹配以“〈更”开头，“\”结尾的字符串，包含开头，不包含结尾
# (?<=〈更).*?(?=\\)   匹配以“〈更”开头，“\”结尾的字符串，不包含开头，不包含结尾

chapter_pattern_extra = r'\n第[\u4e00-\u9fa5]{1,2}章.*\n'  #前后换行，在第 和 章之间有一到两个中文字符
```
