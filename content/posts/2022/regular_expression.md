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



<script>
        require(['echarts', 'echarts-gl', 'china'], function(echarts) {
                var chart_a374ea3793fa488199db586672949b09 = echarts.init(
                    document.getElementById('a374ea3793fa488199db586672949b09'), 'white', {renderer: 'canvas'});
                var option_a374ea3793fa488199db586672949b09 = {
    "animation": true,
    "animationThreshold": 2000,
    "animationDuration": 1000,
    "animationEasing": "cubicOut",
    "animationDelay": 0,
    "animationDurationUpdate": 300,
    "animationEasingUpdate": "cubicOut",
    "animationDelayUpdate": 0,
    "color": [
        "#c23531",
        "#2f4554",
        "#61a0a8",
        "#d48265",
        "#749f83",
        "#ca8622",
        "#bda29a",
        "#6e7074",
        "#546570",
        "#c4ccd3",
        "#f05b72",
        "#ef5b9c",
        "#f47920",
        "#905a3d",
        "#fab27b",
        "#2a5caa",
        "#444693",
        "#726930",
        "#b2d235",
        "#6d8346",
        "#ac6767",
        "#1d953f",
        "#6950a1",
        "#918597"
    ],
    "series": [
        {
            "type": "bar3D",
            "name": "\u4e8c\u624b\u623f\u4ef7 \u5143/\u33a1",
            "coordinateSystem": "geo3D",
            "grid3DIndex": 0,
            "geo3DIndex": 0,
            "globeIndex": 0,
            "barSize": 1,
            "bevelSize": 0,
            "bevelSmoothness": 2,
            "minHeight": 2,
            "label": {
                "show": false,
                "position": "top",
                "margin": 8,
                "formatter": function(data){return data.name + ' ' + data.value[2];}
            },
            "emphasis": {},
            "data": [
                {
                    "name": "\u5317\u4eac",
                    "value": [
                        116.407526,
                        39.90403,
                        88269
                    ]
                },
                {
                    "name": "\u5929\u6d25",
                    "value": [
                        117.200983,
                        39.084158,
                        30484
                    ]
                },
                {
                    "name": "\u6cb3\u5317\u6ca7\u5dde",
                    "value": [
                        116.838834,
                        38.304477,
                        10069
                    ]
                },
                {
                    "name": "\u8fbd\u5b81\u5927\u8fde",
                    "value": [
                        121.614682,
                        38.914003,
                        20872
                    ]
                },
                {
                    "name": "\u4e0a\u6d77",
                    "value": [
                        121.473701,
                        31.230416,
                        73571
                    ]
                },
                {
                    "name": "\u6c5f\u82cf\u5357\u4eac",
                    "value": [
                        118.796877,
                        32.060255,
                        27603
                    ]
                },
                {
                    "name": "\u6c5f\u82cf\u82cf\u5dde",
                    "value": [
                        120.585315,
                        31.298886,
                        30148
                    ]
                },
                {
                    "name": "\u6d59\u6c5f\u676d\u5dde",
                    "value": [
                        120.15507,
                        30.274084,
                        43215
                    ]
                },
                {
                    "name": "\u5b89\u5fbd\u6ec1\u5dde",
                    "value": [
                        118.317106,
                        32.301556,
                        7435
                    ]
                },
                {
                    "name": "\u798f\u5efa\u798f\u5dde",
                    "value": [
                        119.296494,
                        26.074507,
                        26537
                    ]
                },
                {
                    "name": "\u6c5f\u897f\u5357\u660c",
                    "value": [
                        115.858197,
                        28.682892,
                        14180
                    ]
                },
                {
                    "name": "\u6c5f\u897f\u8d63\u5dde",
                    "value": [
                        114.935029,
                        25.831829,
                        13111
                    ]
                },
                {
                    "name": "\u6c5f\u897f\u5b9c\u6625",
                    "value": [
                        114.416778,
                        27.815619,
                        21256
                    ]
                },
                {
                    "name": "\u5c71\u4e1c\u9752\u5c9b",
                    "value": [
                        120.382639,
                        36.067082,
                        24128
                    ]
                },
                {
                    "name": "\u6cb3\u5357\u90d1\u5dde",
                    "value": [
                        113.625368,
                        34.746599,
                        16156
                    ]
                },
                {
                    "name": "\u6e56\u5317\u6b66\u6c49",
                    "value": [
                        114.305392,
                        30.593098,
                        19221
                    ]
                },
                {
                    "name": "\u6e56\u5357\u957f\u6c99",
                    "value": [
                        112.938814,
                        28.228209,
                        11945
                    ]
                },
                {
                    "name": "\u5e7f\u4e1c\u5e7f\u5dde",
                    "value": [
                        113.264434,
                        23.129162,
                        41430
                    ]
                },
                {
                    "name": "\u5e7f\u4e1c\u6df1\u5733",
                    "value": [
                        114.057868,
                        22.543099,
                        74100
                    ]
                },
                {
                    "name": "\u91cd\u5e86",
                    "value": [
                        106.551556,
                        29.563009,
                        14351
                    ]
                },
                {
                    "name": "\u56db\u5ddd\u6210\u90fd",
                    "value": [
                        104.066541,
                        30.572269,
                        20016
                    ]
                },
                {
                    "name": "\u9655\u897f\u897f\u5b89",
                    "value": [
                        108.940174,
                        34.341568,
                        21786
                    ]
                },
                {
                    "name": "\u7518\u8083\u5170\u5dde",
                    "value": [
                        103.834303,
                        36.061089,
                        12829
                    ]
                }
            ],
            "shading": "lambert",
            "zlevel": -10,
            "silent": false,
            "animation": true,
            "animationDurationUpdate": 100,
            "animationEasingUpdate": "cubicOut"
        }
    ],
    "legend": [
        {
            "data": [
                "\u4e8c\u624b\u623f\u4ef7 \u5143/\u33a1"
            ],
            "selected": {
                "\u4e8c\u624b\u623f\u4ef7 \u5143/\u33a1": true
            },
            "show": true,
            "padding": 5,
            "itemGap": 10,
            "itemWidth": 25,
            "itemHeight": 14
        }
    ],
    "tooltip": {
        "show": true,
        "trigger": "item",
        "triggerOn": "mousemove|click",
        "axisPointer": {
            "type": "line"
        },
        "showContent": true,
        "alwaysShowContent": false,
        "showDelay": 0,
        "hideDelay": 100,
        "textStyle": {
            "fontSize": 14
        },
        "borderWidth": 0,
        "padding": 5
    },
    "geo3D": {
        "map": "china",
        "boxWidth": 100,
        "boxHeight": 10,
        "regionHeight": 3,
        "groundPlane": {
            "show": false,
            "color": "#aaa"
        },
        "instancing": false,
        "itemStyle": {
            "color": "rgb(5,101,123)",
            "borderColor": "rgb(62,215,213)",
            "borderWidth": 0.8,
            "opacity": 1
        },
        "label": {
            "show": false,
            "formatter": function(data){return data.name +  + data.value[2];}
        },
        "emphasis": {
            "label": {
                "show": false,
                "position": "top",
                "color": "#fff",
                "margin": 8,
                "fontSize": 10,
                "backgroundColor": "rgba(0,23,11,0)"
            }
        },
        "light": {
            "main": {
                "color": "#fff",
                "intensity": 1.2,
                "shadow": false,
                "shadowQuality": "high",
                "alpha": 40,
                "beta": 10
            },
            "ambient": {
                "color": "#fff",
                "intensity": 0.3
            },
            "ambientCubemap": {
                "diffuseIntensity": 0.5,
                "specularIntensity": 0.5
            }
        },
        "temporalSuperSampling": {
            "enable": "auto"
        },
        "zlevel": -10,
        "left": "auto",
        "top": "auto",
        "right": "auto",
        "bottom": "auto",
        "width": "auto",
        "height": "auto"
    },
    "title": [
        {
            "text": "\u4e8c\u624b\u623f\u4ef7\u5730\u56fe\u5c55\u793a\uff08\u4e0d\u5b8c\u6574\u5730\u56fe\u6a21\u578b\uff09",
            "padding": 5,
            "itemGap": 10
        }
    ]
};
                chart_a374ea3793fa488199db586672949b09.setOption(option_a374ea3793fa488199db586672949b09);
        });
    </script>
