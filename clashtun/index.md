# TUN模式 Clash for windows 配置教程


首先理解TUN模式，这是一个真正意义上的全局的代理模式，它会在你的网络适配器中新建一个Clash专用的，可以理解为软路由中转网卡，开启TUN模式如下图所示。

![img](MD_img/clip_image001.png)

然后可以在网络适配器中找到Clash专用的网络适配器，所有进入本机的流量都会经过这个适配器，如下图所示

 

![img](MD_img/clip_image002.png)

双击打开它进行如下设置，注意更改DNS解析，如果Clash给了默认的有可能导致网页无法打开，选择自动获取DNS服务器地址即可。

![img](MD_img/clip_image003.png)

 

然后回到Clash，一般机场给的配置文件里都会有规则，我们切换到按规则选择节点即可，如下图所示

 

![img](MD_img/clip_image004.png)

然后我们打开浏览器进行测试，分别访问[www.google.com](http://www.google.com) 和 [www.baidu.com](http://www.baidu.com) ，这里不进行演示了。

访问完了之后我们到clash进行检查一下看下流量怎么走的，如下图所示，可以看到前者是走了代理的，而后者是直连。

![img](MD_img/clip_image005.png)

