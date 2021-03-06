# 记一次Clash for Linux 的配置


室友帮忙弄的clash又不行了，今天打算自己修修（重装）这个梯子软件，记录一下。

现在的病情就是谷歌上不去，如下图所示。

![image-20220423185159155](MD_img/image-20220423185159155.png)

clash的网页配置端口也上不去。

<img src="MD_img/image-20220423185318890.png" alt="image-20220423185318890" style="zoom: 50%;" />

## 准备工具

首先我们要使用一台能够访问外网的机器来下载必要的文件，经典悖论，没错，上外网下clash用来上外网，不过github还是有几率能上去的。

到clash开源工具(go 写的)的repo地址下载最新的release，比如我本次下载的是版本。[传送门](https://github.com/Dreamacro/clash)

所使用的Linux系统是

```
lsb_release -a
```

![image-20220423214758371](MD_img/image-20220423214758371.png)

## 开始安装

首先解压下载的release文件在你想要的目录。比如我的在家目录的clash文件夹下。

```bash
gunzip clash-linux-amd64-v1.10.0.gz
```

然后进行第一次运行clash

```bash
chmod +x clash-linux-amd64-v1.10.0(换成自己的clash版本)
```

```bash
./clash-linux-amd64-v1.10.0(换成自己的clash版本)
```



![image-20220423221233323](MD_img/image-20220423221233323.png)

端口被占用了……

查看是哪个进程占用了端口并kill

```bash
sudo lsof -i tcp:7890
```

```bash
kill 11556(换成你自己找到的PID)
```

![image-20220423221454098](MD_img/image-20220423221454098.png)

再试一次，ok启动了……

![image-20220423221607747](MD_img/image-20220423221607747.png)

这个时候，我们可以在用户家目录的.config/文件夹下找到自动生成的clash文件夹

![image-20220423221907173](MD_img/image-20220423221907173.png)

## 后续更新URL从这里开始

然后我们使用运营商给的订阅链接输入浏览器网址，把内容全部复制到config.yaml文件里

![image-20220423222502739](MD_img/image-20220423222502739.png)

```bash
vi ~/.config/clash/config.yaml（不推荐直接复制粘贴网页内容，建议往后看）
```

这种方式非常慢，由于页面文本较长，长时间在粘贴……

![image-20220423222950126](MD_img/image-20220423222950126.png)

果断关掉重来，我们将刚刚链接打开的网页右键另存为一个文件

![image-20220423223206029](MD_img/image-20220423223206029.png)

然后重定向写入config.yaml文件，一秒钟搞定

![image-20220423223355043](MD_img/image-20220423223355043.png)

### 改完config之后，后续更新URL的操作至此完成

写好了config文件之后，我们启动试试。**顺便先在对应目录下给clash的可执行文件改个名**

```
mv clash-linux-amd64-v1.10.0 clash

./clash
```



![image-20220424105818447](MD_img/image-20220424105818447.png)

使用谷歌浏览器的端口代理插件设置网页代理端口为自己主机的7890如下

![image-20220423223851685](MD_img/image-20220423223851685.png)



访问Google

![image-20220423224221943](MD_img/image-20220423224221943.png)

OK正常

如果你想使用本机端口服务做代理然后在命令行进行访问，可以使用

```
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
```

```ba
# 随便使用命令行git上下载一个包试试
wget https://github.com/pyenv/pyenv/archive/refs/tags/v2.2.5.zip
```



<img src="MD_img/image-20220424103507133.png" alt="image-20220424103507133" style="zoom:80%;" />

好使

## 基本功能完成，后续设置开机启动。

将功能设置为一个service

增加system配置

```ba
vi /etc/systemd/system/clash.service

```

写入以下内容,注意，一定

```ba
[Unit]
Description=Clash service
After=network.target

[Service]
Type=simple
User=oliver #换成你自己用户名
/home/oliver/clash/clash -d /home/oliver/.config/clash/   #换成你自己clash目录，注意，前半部分一定要连接到文件！不能只到目录
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
```

<img src="MD_img/image-20220424110713728.png" alt="image-20220424110713728" style="zoom:80%;" />

```bash
sudo systemctl daemon-reload
sudo systemctl enable clash
sudo systemctl start clash
sudo systemctl status clash
```

![image-20220424110642415](MD_img/image-20220424110642415.png)

OK，成功了，图中端口9090是UI的端口，意味着访问http://127.0.0.1:9090就能出现如下界面

<img src="MD_img/image-20220424110950514.png" alt="image-20220424110950514" style="zoom:50%;" />

至此结束~

```bash
echo "至此结束~"
```






