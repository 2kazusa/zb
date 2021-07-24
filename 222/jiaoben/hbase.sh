#!/bin/bash

#1.解压hadoop压缩包，设定hadoop安装路径
echo -e "请输入hbase的安装目录,例如/usr/local/opt/install"
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

#解压zookeeper压缩包了
currentdir=$(cd $(dirname $0);pwd)
ls | grep 'hbase-.*[gz]$'
if [ $? -ne 0 ]; then
  echo "在$currentdir没有发现hbase压缩包，上传到该路径下"
  exit
else
  tar -zxvf $currentdir/$(ls | ls | grep 'hbase-.*[gz]$') -C $installpath
fi

#配置zookeeper环境变量
#zookeeper路径
esbanben=`ls $installpath | grep 'hbase-.*'`

#配置/etc/profile 配置环境变量 hbase
echo "">>/etc/profile
echo '#hbase'>>/etc/profile
echo "export HBASE_HOME=$installpath/$esbanben">>/etc/profile
echo 'export PATH=$PATH:$HBASE_HOME/bin'>>/etc/profile
source /etc/profile

#配置
hbasedir=$installpath/$esbanben  #完整路径
confdir=$installpath/$esbanben/conf #完成配置文件路径

echo "">>$confdir/hbase-env.sh
echo 'export HBASE_MANAGES_ZK=true'>>$confdir/hbase-env.sh
echo 'export JAVA_HOME='`echo $JAVA_HOME`>>$confdir/hbase-env.sh

echo "请输入hbase的数据存放的文件夹名称"
read hbasedata
sed -i '/<\/configuration>/i\ <!--hbase-->' $confdir/hbase-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/hbase-site.xml
sed -i '/<\/configuration>/i\ <name>hbase.rootdir</name>' $confdir/hbase-site.xml
sed -i "/<\/configuration>/i\ <value>$hbasedir/$hbasedata</value>" $confdir/hbase-site.xml
sed -i "/<\/configuration>/i\ </property>" $confdir/hbase-site.xml

sed -i '/<\/configuration>/i\ <!--hbase-->' $confdir/hbase-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/hbase-site.xml
sed -i '/<\/configuration>/i\ <name>hbase.cluster.distributed</name>' $confdir/hbase-site.xml
sed -i "/<\/configuration>/i\ <value>true</value>" $confdir/hbase-site.xml
sed -i "/<\/configuration>/i\ </property>" $confdir/hbase-site.xml

mkdir -p -m 777 $hbasedir/$hbasedata

