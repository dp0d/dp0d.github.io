# TUN模式 Clash for windows 配置教程


### TUN模式

首先理解TUN模式，这是一个真正意义上的全局的代理模式，它会在你的网络适配器中新建一个Clash专用的，可以理解为软路由中转网卡，开启TUN模式如下图所示。

![image-20230714083622961](MD_img/image-20230714083622961.png)

![img](MD_img/clip_image001.png)

然后可以在网络适配器中找到clash for windows 客户端专用的网络适配器，所有进入本机的流量都会经过这个适配器，如下图所示

 

![img](MD_img/clip_image002.png)

双击打开它进行如下设置，注意更改DNS解析，如果clash for windows 客户端给了默认的有可能导致网页无法打开，选择自动获取DNS服务器地址即可。

![img](MD_img/clip_image003.png)

 

然后回到clash for windows 客户端，一般机场给的配置文件里都会有规则，我们切换到按规则选择节点即可，如下图所示

 

![img](MD_img/clip_image004.png)

然后我们打开浏览器进行测试，分别访问百度和古🐶，这里不进行演示了。

访问完了之后我们到clash for windows 客户端进行检查一下看下流量怎么走的，如下图所示，可以看到前者是走了代理的，而后者是直连。

![img](MD_img/clip_image005.png)



### Proxy SwitchyOmega 插件模式

如果你的#Clash规则不好用，或是#只需要浏览器代理，可以借用Proxy SwitchyOmega浏览器插件来完成代理。

以谷歌浏览器为例，Edge应该也有，先在应用商店找到这个插件，然后安装到浏览器上

<img src="MD_img/image-20230714084252725.png" alt="image-20230714084252725" style="zoom:25%;" />

完成后你的浏览器上应该会出现以下标志在插件栏里

<img src="MD_img/image-20230714085004649.png" alt="image-20230714085004649" style="zoom:33%;" />

基于Proxy SwitchyOmega，你可以选择两种规则方式，下面分别介绍这两种方式的具体设置。

#### 方式一  使用clash自带规则

> 首先打开clash for windows客户端，确认clash服务端口

如下图所示，记住这个端口（可以自行设置）。  **7890**

<img src="MD_img/image-20230714085446701.png" alt="image-20230714085446701"  />



> 然后回到浏览器，打开Proxy SwitchyOmega插件的选项卡

<img src="MD_img/image-20230714085646686.png" alt="image-20230714085646686" style="zoom:33%;" />

> 新建一个名为clash的情景模式，并做好如下设置保存

![image-20230714090137885](MD_img/image-20230714090137885.png)

<img src="MD_img/image-20230714090234585.png" alt="image-20230714090234585" style="zoom:33%;" />

下图中的代理端口改为刚刚记住的端口，代理协议和服务器如图所示为HTTP和本地回环地址。

![image-20230714091936173](MD_img/image-20230714091936173.png)





> 接下来我们回到clash for windows 客户端，设置按规则代理

![image-20230714090911839](MD_img/image-20230714090911839.png)

> 打开浏览器，选择我们刚刚设置的插件情景模式

<img src="MD_img/image-20230714090950912.png" alt="image-20230714090950912" style="zoom:33%;" />





访问百度和古🐶

> 回到clash for windows 客户端查看访问测试

![image-20230714091424977](MD_img/image-20230714091424977.png)

**分流成功**



#### 方式二  使用网络来源规则

> 打开浏览器插件，在建立好方式一中浏览器clash情景模式的基础下新建一个auto switch情景模式

<img src="MD_img/image-20230714091812543.png" alt="image-20230714091812543" style="zoom:25%;" />





> 对这个情景模式进行如下设置

使用这个开源规则列表（也可以替换成别的）

https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt

![image-20230714092158521](MD_img/image-20230714092158521.png)





> 完成设置后我们回到clash for windows 客户端，设置指定代理

![image-20230714092548732](MD_img/image-20230714092548732.png)



> 回到浏览器打开插件的auto switch情景模式

<img src="MD_img/image-20230714093144497.png" alt="image-20230714093144497" style="zoom:25%;" />

访问百度和古🐶

>  回到clash for windows 客户端查看访问测试

![image-20230714093014248](MD_img/image-20230714093014248.png)



可以看到，clash for windows 客户端在访问百度时压根没有connection记录，说明Proxy SwitchyOmega插件使得浏览器在访问某些网站时没有走代理，而某些网站走了代理。

**分流成功**



#### 某GPT更换节点设置方法

当某GPT挂了时，按照Proxy SwitchyOmega插件插件方式二设置，并尝试切换不同地域节点即可。

![image-20230714093836126](MD_img/image-20230714093836126.png)

