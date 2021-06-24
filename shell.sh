#! /bin/bash
#====================================
#     Hadoop自动安装V2.0 by:MC_cubes
#====================================

HADOOP_V='2.8.5'
# 获取当前目录
echo "当前目录:"
echo "Current directory:"
cd ~
BASE_PATH=$(cd `dirname $0`; pwd)
echo $BASE_PATH
source $BASE_PATH/.bashrc

if [[ $1 == "start" ]];then
  start-dfs.sh && start-yarn.sh
  exit 0
elif [[ $1 == "stop" ]];then
  stop-all.sh
  exit 0
elif [[ $1 == "ini" ]];then
  hdfs namenode -format
  exit 0
elif [[ $1 == "clear" ]];then
  rm -rf ~/tmp
  exit 0
elif [[ $1 == "IS" ]];then
  hdfs namenode -format
  start-dfs.sh && start-yarn.sh
  exit 0
fi

echo ""
echo "===作者:MC_cubes==="
echo "===By:MC_cubes==="
echo "V2.0"
echo ""
echo "===接下来开始安装Hadoop(伪分布式配置)==="
echo "请确保此用户能够使用sudo,"
echo "且网络配置正常,JAVA_HOME环境变量设置完成,"
echo "用户根目录下(~)存在hadoop-2.8.5.tar.gz"
echo "首次运行本脚本建议删除 ~/hadoop 文件夹"
echo "===按ENTER键继续，Ctrl + C退出==="

echo "===Next, start installing Hadoop(Pseudo distributed configuration)==="
echo "Please make sure that this user can use sudo,"
echo "And the network configuration is normal, JAVA_HOME environment variable is set,"
echo "Hadoop-2.8.5.tar.gz exists in the user's directory (~)"
echo "It is recommended to delete the ~/hadoop folder when running this script for the first time"
echo "===Press ENTER to continue,Ctrl + C to exit==="
read anykey

# 检测用户Current user
echo "当前用户:"
echo "Current user:"
userName=$(env | grep USER | cut -d "=" -f 2)
hostName=$(hostname -s)
echo $userName
echo $hostName

mkdir $BASE_PATH/.ssh/
cd $BASE_PATH/.ssh/
if [ ! -e "authorized_keys" ];then
	# SSH免密码登录配置
  ssh=`command -v ssh` 
  if [ -n "$ssh" ];then
    apt=`command -v apt-get` 
    yum=`command -v yum`
    if [ -n "$apt" ]; then
      sudo apt-get -y install openssh-server
    elif [ -n "$yum" ]; then
      sudo yum install openssh-server
    else
      echo "===ERROR==="
	    echo "找不到apt-get和yum"
	    echo "No path to apt-get or yum";
	    echo "===ERROR==="
      exit 0; 
    fi
  fi
  echo "当前正在设置SSH免密码登录:"
  echo "请按ENTER键或输入yes:"
  echo "Currently setting SSH password free login:"
  echo "Please press Enter or enter yes:"
  ssh-keygen -t rsa
  cat ./id_rsa.pub >> ./authorized_keys
  # 测试
  echo "当前正在测试SSH免密码登录:"
  echo "请输入exit或输入yes:"
  echo "Currently testing SSH password free login:"
  echo "Please enter the exit or enter yes:"
  ssh $hostName
else
  echo "SSH OK!"
fi

cd ~
echo ""
if [ ! -e "${BASE_PATH}/hadoop-${HADOOP_V}.tar.gz" ];then
	echo "===ERROR==="
	echo "找不到 hadoop-${HADOOP_V}.tar.gz"
	echo "Can't find hadoop-${HADOOP_V}.tar.gz"
	echo "===ERROR==="
	echo "脚本停止执行"
  echo "Shell stop"
	exit 0
fi

if [ ! -d "hadoop/" ];then
  echo "Hadoop正在解压..."
  echo "Hadoop unzipping..."
  sudo tar -zxvf "hadoop-${HADOOP_V}.tar.gz"
  sudo mv "hadoop-${HADOOP_V}" hadoop
  sudo chown -R $userName:$userName hadoop
  echo "Hadoop解压完成!"
  echo "Hadoop unzip complete!"
  HADOOP_PATH="${BASE_PATH}/hadoop"
  echo $HADOOP_PATH
else
  echo "Hadoop已经存在!"
  echo "Hadoop exist!"
  sudo chown -R $userName:$userName hadoop
  HADOOP_PATH="${BASE_PATH}/hadoop"
  echo $HADOOP_PATH
fi

# 环境变量配置
echo "Hadoop环境变量配置..."
echo "Hadoop EV configuration..."
if [ $HADOOP_HOME="${HADOOP_PATH} $BASE_PATH/.bashrc" ];then
  echo "Hadoop环境变量已存在!"
  echo "Hadoop EV exist!"
else
  sudo sed -i '$aexport HADOOP_HOME='${HADOOP_PATH} $BASE_PATH/.bashrc
  sudo sed -i '$aexport PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin' $BASE_PATH/.bashrc
  source $BASE_PATH/.bashrc
  sudo sed -i '$aexport HADOOP_HOME='${HADOOP_PATH} /etc/profile
  sudo sed -i '$aexport PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin' /etc/profile
  source /etc/profile
fi

# Hadoop配置JDK
echo "Hadoop配置JDK..."
echo $JAVA_HOME
sed -i "26iexport JAVA_HOME="$JAVA_HOME $HADOOP_PATH/etc/hadoop/hadoop-env.sh
sed -i "25d" $HADOOP_PATH/etc/hadoop/hadoop-env.sh
source $HADOOP_PATH/etc/hadoop/hadoop-env.sh
echo ""

# hadoop获取版本测试
if [ ! "$(hadoop version | head -n 1)" == "Hadoop 2.8.5" ];then
  echo "===ERROR==="
  echo "获取hadoop版本失败,安装失败!"
  echo "Failed to get Hadoop version, failed to install!"
  echo "===ERROR==="
	echo "脚本停止执行"
  echo "Shell stop"
	exit 0
else
  echo "获取hadoop版本成功!"
  echo "Get Hadoop version successfully!"
fi

# 伪分布式配置
echo ""
echo "开始伪分布式配置"
# 配置core-site.xml
sed -i '18,$d' $HADOOP_PATH/etc/hadoop/core-site.xml
echo "<configuration>" >> $HADOOP_PATH/etc/hadoop/core-site.xml

echo "  <property>" >> $HADOOP_PATH/etc/hadoop/core-site.xml
echo "      <name>fs.defaultFS</name>" >> $HADOOP_PATH/etc/hadoop/core-site.xml
echo "      <value>hdfs://$hostName:9000</value>" >> $HADOOP_PATH/etc/hadoop/core-site.xml
echo "  </property>" >> $HADOOP_PATH/etc/hadoop/core-site.xml

echo "  <property>" >> $HADOOP_PATH/etc/hadoop/core-site.xml
echo "      <name>hadoop.tmp.dir</name>" >> $HADOOP_PATH/etc/hadoop/core-site.xml
echo "      <value>${BASE_PATH}/tmp/hadoop</value>" >> $HADOOP_PATH/etc/hadoop/core-site.xml
echo "  </property>" >> $HADOOP_PATH/etc/hadoop/core-site.xml

echo "</configuration>" >> $HADOOP_PATH/etc/hadoop/core-site.xml
echo "core-site.xml 配置完成ok!"

# 配置hdfs-site.xml
sed -i '18,$d' $HADOOP_PATH/etc/hadoop/hdfs-site.xml
echo "<configuration>" >> $HADOOP_PATH/etc/hadoop/hdfs-site.xml

echo "  <property>" >> $HADOOP_PATH/etc/hadoop/hdfs-site.xml
echo "      <name>dfs.replication</name>" >> $HADOOP_PATH/etc/hadoop/hdfs-site.xml
echo "      <value>1</value>" >> $HADOOP_PATH/etc/hadoop/hdfs-site.xml
echo "  </property>" >> $HADOOP_PATH/etc/hadoop/hdfs-site.xml

echo "  <property>" >> $HADOOP_PATH/etc/hadoop/hdfs-site.xml
echo "      <name>dfs.secondary.http.address</name>" >> $HADOOP_PATH/etc/hadoop/hdfs-site.xml
echo "      <value>$hostName:9001</value>" >> $HADOOP_PATH/etc/hadoop/hdfs-site.xml
echo "  </property>" >> $HADOOP_PATH/etc/hadoop/hdfs-site.xml

echo "</configuration>" >> $HADOOP_PATH/etc/hadoop/hdfs-site.xml
echo "hdfs-site.xml 配置完成ok!"

# 复制mapred-site.xml.template
cp $HADOOP_PATH/etc/hadoop/mapred-site.xml.template $HADOOP_PATH/etc/hadoop/mapred-site.xml
# 配置mapred-site.xml
sed -i '18,$d' $HADOOP_PATH/etc/hadoop/mapred-site.xml
echo "<configuration>" >> $HADOOP_PATH/etc/hadoop/mapred-site.xml

echo "  <property>" >> $HADOOP_PATH/etc/hadoop/mapred-site.xml
echo "      <name>mapreduce.framework.name</name>" >> $HADOOP_PATH/etc/hadoop/mapred-site.xml
echo "      <value>yarn</value>" >> $HADOOP_PATH/etc/hadoop/mapred-site.xml
echo "  </property>" >> $HADOOP_PATH/etc/hadoop/mapred-site.xml

echo "</configuration>" >> $HADOOP_PATH/etc/hadoop/mapred-site.xml
echo "mapred-site.xml 配置完成ok!"

# 配置yarn-site.xml
sed -i '15,$d' $HADOOP_PATH/etc/hadoop/yarn-site.xml
echo "<configuration>" >> $HADOOP_PATH/etc/hadoop/yarn-site.xml

echo "  <property>" >> $HADOOP_PATH/etc/hadoop/yarn-site.xml
echo "      <name>yarn.nodemanager.aux-services</name>" >> $HADOOP_PATH/etc/hadoop/yarn-site.xml
echo "      <value>mapreduce_shuffle</value>" >> $HADOOP_PATH/etc/hadoop/yarn-site.xml
echo "  </property>" >> $HADOOP_PATH/etc/hadoop/yarn-site.xml

echo "</configuration>" >> $HADOOP_PATH/etc/hadoop/yarn-site.xml
echo "yarn-site.xml 配置完成ok!"

rm -rf $BASE_PATH/tmp

echo "======Hadoop伪分布式配置完成!======"
echo "======Hadoop pseudo distributed configuration complete!======"
echo ""
echo ""
echo "          Enjoy it ! :)"
echo "            See you ~"
echo ""
echo ""
echo "======执行命令"IS"来初始化并运行Hadoop!======"
echo "======Execute the "IS" command to initialize and run Hadoop!======"
echo "脚本命令:"
echo "Script command:"
echo "0.(没有参数),安装"
echo "1.start,    启动Hadoop"
echo "2.stop,     关闭Hadoop"
echo "3.ini,      初始化Hadoop"
echo "4.clear,    清除缓存"
echo "5.IS ,      初始化并运行Hadoop"
echo "0.(none),   Install"
echo "1.start,    Start Hadoop"
echo "2.stop,     Stop Hadoop"
echo "3.ini,      Initialize Hadoop"
echo "4.clear,    Del tmp"
echo "5.IS ,      Initialize and start Hadoop"
