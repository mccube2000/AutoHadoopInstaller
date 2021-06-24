[CSDN](https://blog.csdn.net/MC_cube/article/details/118194127)
# 脚本简介

&ensp;&ensp;最近学习了Linux下**Hadoop伪分布式**安装的方法，在自己手动成功安装后，尝试编写了一个shell脚本来自动完成安装过程。  
&ensp;&ensp;脚本有些不太完善的地方，且以尽量少修改配置文件为目标编写。有任何问题欢迎指出。  
&ensp;&ensp;脚本中包括中英文两种语言的提示，英文有部分为机翻，可能不太准确。  
# 准备工作
## Java环境
&ensp;&ensp;确保已经安装java，已经设置 `JAVA_HOME`环境变量。
验证：输入  
```shell
$JAVA_HOME
```
&ensp;&ensp;显示正确的java路径。  
## 网络配置
&ensp;&ensp;自己的网络配置正常。  
&ensp;&ensp;验证：能够ping通百度和自己的主机名  
```shell
ping www.baidu.com
ping $(hostname)
```
&ensp;&ensp;如果ping不通百度，可以设置一下DNS再试试。  
&ensp;&ensp;如果ping不通自己的主机名，可以修改一下`/etc/hostname`和`/etc/hosts`。  
## Hadoop安装文件
&ensp;&ensp;将文件名如`hadoop-2.8.5.tar.gz`的Hadoop安装文件放在运行脚本用户的用户文件夹下(~)。如果版本不是`2.8.5`，可以在脚本第六行修改。  
# 脚本运行
&ensp;&ensp;在脚本所在目录执行(脚本名默认shell.sh)：  
```shell
./shell.sh
```
&ensp;&ensp;然后根据提示完成部署。除了设置SSH免密码登录外，基本是全自动的。  
# 脚本命令
&ensp;&ensp;脚本包括以下几个命令：  
(没有参数)，安装  
1. start，启动Hadoop
2. stop，关闭Hadoop
3. ini，初始化Hadoop
4. clear，清除缓存
5. IS，初始化并运行Hadoop

&ensp;&ensp;首次安装完成直接执行：  
```shell
./shell.sh IS
```
&ensp;&ensp;即可初始化并运行Hadoop。  
# 脚本下载
&ensp;&ensp;可以直接前往我的[GitHub](https://github.com/mccube2000/AutoHadoopInstaller)下载脚本，希望大家能给我一个`Star`。如果上不去或者想要支持作者的话，可以在[这里](https://download.csdn.net/download/MC_cube/19813900)下载。
