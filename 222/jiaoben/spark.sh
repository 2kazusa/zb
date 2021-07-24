#!/bin/bash

#1.解压hadoop压缩包，设定hadoop安装路径
echo -e "请输入spark的安装目录,例如/usr/local/opt/install"
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

#解压spark压缩包了
currentdir=$(cd $(dirname $0);pwd)
ls | grep 'spark-.*[gz]$'
if [ $? -ne 0 ]; then
  echo "在$currentdir没有发现spark压缩包，上传到该路径下"
  exit
else
  tar -zxvf $currentdir/$(ls | ls | grep 'spark-.*[gz]$') -C $installpath
fi

#配置zookeeper环境变量
#zookeeper路径
esbanben=`ls $installpath | grep 'spark-.*'`

#配置/etc/profile 配置环境变量 hbase
echo "">>/etc/profile
echo '#spark'>>/etc/profile
echo "export SPARK_HOME=$installpath/$esbanben">>/etc/profile
echo 'export PATH=$PATH:$SPARK_HOME/bin'>>/etc/profile
source /etc/profile

#配置
sparkdir=$installpath/$esbanben  #完整路径
confdir=$installpath/$esbanben/conf #完成配置文件路径

cp $confdir/spark-env.sh.template $confdir/spark-env.sh

echo "">>$confdir/spark-env.sh
echo 'export JAVA_HOME='`echo $JAVA_HOME`>>$confdir/spark-env.sh
echo 'export SPARK_MASTER_HOST=master'>>$confdir/spark-env.sh
