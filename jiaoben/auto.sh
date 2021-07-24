#!/bin/bash
#使用/bin/bash解释执行shell脚本

#1.解压hadoop压缩包，设定hadoop安装路径
#echo "" 输出字符串内容。-e是输出转义内容，这里没用到。
echo -e "请输入hadoop的安装目录,例如/usr/local/opt/install"
#从标准输入读取输入并赋值给变量installpath,若读取多个变量可以用space隔开
read installpath

#创建该目录  ! -d $installpath 找这个路径下有没有这个目录，有就返回真
if [ ! -d $installpath ]; then
  mkdir -p $installpath
fi

#判断它是否成功
if [ ! -d $installpath ]; then
  echo "创建目录失败，请查看有没有权限"
  exit
fi

#解压hadoop压缩包
#对currentdir的解析https://www.cnblogs.com/turbolxq/p/10408414.html
currentdir=$(cd $(dirname $0);pwd)
#显示当前目录下符合'hadoop-.*[gz]$'正则式的文件
ls | grep 'hadoop-.*[gz]$'
#$?表示上一个命令的退出状态，执行成功返回0
if [ $? -ne 0 ]; then
  echo "在$currentdir没有发现hadoop压缩包，上传到该路径下"
  exit
else
  tar -zxvf $currentdir/$(ls | ls | grep 'hadoop-.*[gz]$') -C $installpath
fi

#配置hadoop环境变量
#hadoop路径，``表示取命令输出的值
esbanben=`ls $installpath | grep 'hadoop-.*'`

#配置/etc/profile 配置环境变量 jdk，>>将字符串追加到文件里
echo "">>/etc/profile
echo '#hadoop'>>/etc/profile
echo "export HADOOP_HOME=$installpath/$esbanben">>/etc/profile
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin'>>/etc/profile

#配置hadoop-env.sh
hadoopdir=$installpath/$esbanben  #完整路径
confdir=$installpath/$esbanben/etc/hadoop #完成配置文件路径

#拿到jdk地址
javahome=`echo $JAVA_HOME`
old_dir='export JAVA_HOME=${JAVA_HOME}'
new_dir='export JAVA_HOME='$javahome
#sed -i表示直接读取修改 s表示替换，末尾加g表示替换每一个匹配的关键字
sed -i "s!${old_dir}!${new_dir}!g" $confdir/hadoop-env.sh

#配置core-site.xml
echo  -e "请输入集群主节点名"
read mymaster
# i\ 表示在当前行前面插入文本
sed -i '/<\/configuration>/i\ <!--hadoop集群主机名-->' $confdir/core-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/core-site.xml
sed -i '/<\/configuration>/i\ <name>fs.defaultFS</name>' $confdir/core-site.xml
sed -i "/<\/configuration>/i\ <value>hdfs://$mymaster:9000</value>" $confdir/core-site.xml
sed -i "/<\/configuration>/i\ </property>" $confdir/core-site.xml

#配置core-site.xml 临时文件
echo  -e "请输入存储临时文件，写文件夹名称"
read tmpname
sed -i '/<\/configuration>/i\ <!--临时存储文件夹-->' $confdir/core-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/core-site.xml
sed -i '/<\/configuration>/i\ <name>hadoop.tmp.dir</name>' $confdir/core-site.xml
sed -i "/<\/configuration>/i\ <value>$hadoopdir/data/$tmpname</value>" $confdir/core-site.xml
sed -i '/<\/configuration>/i\ </property>' $confdir/core-site.xml

#mkdir -p创建一条完整路径 -m创建目录时设置权限
mkdir -p -m 777 $hadoopdir/data/$tmpname

echo "core-site.xml配置如下"
cat $confdir/core-site.xml
echo "配置完成"
sleep 1

#hdfs-site.xml
sed -i '/<\/configuration>/i\ <!--hadoop副本数-->' $confdir/hdfs-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/hdfs-site.xml
sed -i '/<\/configuration>/i\ <name>dfs.replication</name>' $confdir/hdfs-site.xml
sed -i '/<\/configuration>/i\ <value>3</value>' $confdir/hdfs-site.xml
sed -i '/<\/configuration>/i\ </property>' $confdir/hdfs-site.xml

echo "请输入namenode文件夹名"
read nnode
sed -i '/<\/configuration>/i\ <!--namenode路径-->' $confdir/hdfs-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/hdfs-site.xml
sed -i '/<\/configuration>/i\ <name>dfs.namenode.name.dir</name>' $confdir/hdfs-site.xml
sed -i "/<\/configuration>/i\ <value>$hadoopdir/data/$nnode</value>" $confdir/hdfs-site.xml
sed -i '/<\/configuration>/i\ </property>' $confdir/hdfs-site.xml
echo "请输入datanode文件夹名"
read dnode
sed -i '/<\/configuration>/i\ <!--datanode路径-->' $confdir/hdfs-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/hdfs-site.xml
sed -i '/<\/configuration>/i\ <name>dfs.datanode.name.dir</name>' $confdir/hdfs-site.xml
sed -i "/<\/configuration>/i\ <value>$hadoopdir/data/$dnode</value>" $confdir/hdfs-site.xml
sed -i '/<\/configuration>/i\ </property>' $confdir/hdfs-site.xml

mkdir -p -m 777 $hadoopdir/data/$nnode
mkdir -p -m 777 $hadoopdir/data/$dnode

echo "hdfs-site.xml配置如下"
cat $confdir/hdfs-site.xml
echo "配置完成"
sleep 1


#配置yarn
echo "请输入集群的主机名"
read yarnname
sed -i '/<\/configuration>/i\ <!--yarn-->' $confdir/yarn-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/yarn-site.xml
sed -i '/<\/configuration>/i\ <name>yarn.resourcemanager.hostname</name>' $confdir/yarn-site.xml
sed -i "/<\/configuration>/i\ <value>$yarnname</value>" $confdir/yarn-site.xml
sed -i '/<\/configuration>/i\ </property>' $confdir/yarn-site.xml


sed -i '/<\/configuration>/i\ <!--NodeManager上运行的附属服务-->' $confdir/yarn-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/yarn-site.xml
sed -i '/<\/configuration>/i\ <name>yarn.nodemanager.aux-services</name>' $confdir/yarn-site.xml
sed -i '/<\/configuration>/i\ <value>mapreduce_shuffle</value>' $confdir/yarn-site.xml
sed -i '/<\/configuration>/i\ </property>' $confdir/yarn-site.xml

echo "yarn-site.xml配置如下"
cat $confdir/yarn-site.xml
echo "配置完成"
sleep 1

cp $confdir/mapred-site.xml.template $confdir/mapred-site.xml
sed -i '/<\/configuration>/i\ <!--mapred-site.xml-->' $confdir/mapred-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/mapred-site.xml
sed -i '/<\/configuration>/i\ <name>mapreduce.framework.name</name>' $confdir/mapred-site.xml
sed -i '/<\/configuration>/i\ <value>yarn</value>' $confdir/mapred-site.xml
sed -i '/<\/configuration>/i\ </property>' $confdir/mapred-site.xml

echo "yarn-site.xml配置如下"
cat $confdir/mapred-site.xml
echo "配置完成"
sleep 1

#配置slaves
echo "请入slaves名称，用空格隔开"
read datanodes

#创建数组array，tr用于替换字符
array=(`echo  $datanodes | tr ' ' ' '`)
#touch用于创建一个不存在的文件
touch $confdir/slaves
: >$confdir/slaves
for datanode in ${array[@]}
  do
    echo $datanode >>$confdir/slaves
  done

cat $confdir/slaves
echo "slaves文件配置完成"


#分发
echo "请输入slave机的名称，用空格隔开"
read allnodes
array=(`echo  $allnodes | tr ' ' ' '`)
  for allnode in ${array[@]}
    do
      echo ===$allnode====
      ssh $allnode "echo ''>>/etc/profile"
      ssh $allnode "echo '#hadoop'>>/etc/profile"
      ssh $allnode "echo 'export HADOOP_HOME=$installpath/$esbanben'>>/etc/profile"
      ssh $allnode "echo 'export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin'>>/etc/profile"
      ssh $allnode "source /etc/profile"
      ssh $allnode "rm -rf $hadoopdir"
      ssh $allnode "mkdir -p $hadoopdir"
      #递归赋值整个目录
      scp -r $hadoopdir/* root@$allnode:$hadoopdir/
      ssh $allnode "chmod 777 $hadoopdir/data/$nnode"
      ssh $allnode "chmod 777 $hadoopdir/data/$dnode"
      echo ====$allnode完成====
    done

