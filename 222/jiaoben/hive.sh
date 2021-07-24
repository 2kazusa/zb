#!/bin/bash

#1.解压hadoop压缩包，设定hadoop安装路径
echo -e "请输入hive的安装目录,例如/usr/local/opt/install"
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

#解压hive压缩包了
currentdir=$(cd $(dirname $0);pwd)
ls | grep 'apache-hive-.*[gz]$'
if [ $? -ne 0 ]; then
  echo "在$currentdir没有发现hive压缩包，上传到该路径下"
  exit
else
  tar -zxvf $currentdir/$(ls | ls | grep 'apache-hive-.*[gz]$') -C $installpath
fi

#配置zookeeper环境变量
#zookeeper路径
esbanben=`ls $installpath | grep 'apache-hive-.*'`

#配置/etc/profile 配置环境变量 hbase
echo "">>/etc/profile
echo '#hive'>>/etc/profile
echo "export HIVE_HOME=$installpath/$esbanben">>/etc/profile
echo 'export PATH=$HIVE_HOME/bin:$PATH'>>/etc/profile

source /etc/profile

#配置
hivedir=$installpath/$esbanben  #完整路径
confdir=$installpath/$esbanben/conf #完成配置文件路径

cp $confdir/hive-default.xml.template $confdir/hive-default.xml
cp $confdir/hive-default.xml.template $confdir/hive-site.xml

sed -i "s!<value>APP</value>!<value>root</value>!g" $confdir/hive-site.xml
sed -i "s!<value>mine</value>!<value>199826</value>!g" $confdir/hive-site.xml
sed -i "s!<value>jdbc:derby:;databaseName=metastore_db;create=true</value>!<value>jdbc:mysql://master:3306/hive</value>!g" $confdir/hive-site.xml
sed -i "s!<value>org.apache.derby.jdbc.EmbeddedDriver</value>!<value>com.mysql.jdbc.Driver</value>!g" $confdir/hive-site.xml



cp $currentdir/$(ls | ls | grep 'mysql-.*[jar]$') $hivedir/lib

hadoop

core-site.xml
fs.defaultFS
hdfs://master:9000

hadoop.tmp.dir
$hadoop_home/data/dir

hdfs-site.xml
dfs.replication
3

dfs.namenode.name.dir
$hadoop_home/data/nnode

dfs.datanode.data.dir
$hadoop_home/data/dnode

yarn-site.xml
yarn.resourcemanager.hostname
master

yarn.nodemanager.aux-services
mapreduce_shuffle

cp mapred.site.xml.template mapred-site.xml
mapreduce.framework.name
yarn

hdfs namenode -format
start-all.sh

zookeeper
cp zoo_sample.cfg zoo.cfg
server.1 = master:2888:3888
server.2 = slave1:2888:3888
server.3 = slave2:2888:3888

master: echo "1">>zookeeper/data/myid
slave1: echo "2">>zookeeper/data/myid
slave2: echo "3">>zookeeper/data/myid
zkServer.sh start 或 bin目录下 ./zkServer.sh start (每台机都要)
zkServer.sh status

hive
cp hive/conf/hive-default.xml.template hive-default.xml
cp hive/conf/hive-default.xml.template hive-site.xml

javax.jdo.option.ConnectionUserName
username

javax.jdo.option.ConnectionPassword
password

javax.jdo.option.ConnectionURL
jdbc:mysql://master:3306/hive

javax.jdo.option.ConnectionDriverName
com.mysql.jdbc.Driver

上传驱动到 /hive/lib

mysql建库 mysql -u root -p
create database hive;
初始化 schematool -dbType mysql initSchema

create table if not exists users(user_id INT,location STRING,age INT)
row format delimited fields terminated by '\;';
load data local inpath "hive-data/Users-prepro.txt" overwrite into
table users;
到hdfs中查看表数据
hdfs dfs -ls /usr/dong/warehouse/users/books.db/users


