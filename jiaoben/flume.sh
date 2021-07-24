#!/bin/bash

#1.解压hadoop压缩包，设定hadoop安装路径
echo -e "请输入flume的安装目录,例如/usr/local/opt/install"
read installpath

#创建该目录  ! -d $installpath 找这个路径下有没有这个目录，有就返回真，假
if [ ! -d $installpath ]; then
  mkdir -p $installpath
fi

#判断它是否成功
if [ ! -d $installpath ]; then
  echo "创建目录失败，请查看有没有权限"
  exit
fi

#解压flume压缩包了
currentdir=$(cd $(dirname $0);pwd)
ls | grep 'apache-flume-.*[gz]$'
if [ $? -ne 0 ]; then
  echo "在$currentdir没有发现flume压缩包，上传到该路径下"
  exit
else
  tar -zxvf $currentdir/$(ls | ls | grep 'apache-flume-.*[gz]$') -C $installpath
fi

#配置zookeeper环境变量
#zookeeper路径
esbanben=`ls $installpath | grep 'apache-flume-.*'`

#配置/etc/profile 配置环境变量 hbase
echo "">>/etc/profile
echo '#flume'>>/etc/profile
echo "export FLUME_HOME=$installpath/$esbanben">>/etc/profile
echo 'export PATH=$FLUME_HOME/bin:$PATH'>>/etc/profile

source /etc/profile

#配置
flumedir=$installpath/$esbanben  #完整路径
confdir=$installpath/$esbanben/conf #完成配置文件路径

cp $confdir/flume-conf.properties.template $confdir/flume-conf.properties

echo "">>$confdir/flume-conf.properties
echo "a1.sources = s1">>$confdir/flume-conf.properties
echo "a1.channels = c1">>$confdir/flume-conf.properties
echo "a1.sinks = k1">>$confdir/flume-conf.properties
echo "a1.sources.s1.type = spooldir">>$confdir/flume-conf.properties
echo 'a1.sources.s1.spoolDir='`echo $HADOOP_HOME`'/logs'>>$confdir/flume-conf.properties
echo "a1.sources.s1.channels = c1">>$confdir/flume-conf.properties
echo "a1.channels.c1.type=memory">>$confdir/flume-conf.properties
echo "a1.sinks.k1.type = hdfs">>$confdir/flume-conf.properties
echo "a1.sinks.k1.hdfs.path=hdfs://master:9000/flume/%Y%m%d">>$confdir/flume-conf.properties
echo "a1.sinks.k1.hdfs.filePrefix=%Y%m%d-">>$confdir/flume-conf.properties
echo "a1.sinks.k1.hdfs.fileType=DataStream">>$confdir/flume-conf.properties
echo "a1.sinks.k1.channel=c1">>$confdir/flume-conf.properties
echo "1.sinks.k1.hdfs.useLocalTimeStamp = true">>$confdir/flume-conf.properties


