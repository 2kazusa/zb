#!/bin/bash

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

hadoop-env.sh
export JAVA_HOME=${JAVA_HOME}

hdfs namenode -format
start-all.sh

zookeeper
cp zoo_sample.cfg zoo.cfg
server.1 = master:2888:3888
server.2 = slave1:2888:3888
server.3 = slave2:2888:3888

scp -r /opt/soft/zookeeper root@slave1:/opt/soft/
scp -r /opt/soft/zookeeper root@slave2:/opt/soft/

scp -r /etc/profile root@slave1:/etc/
scp -r /etc/profile root@slave2:/etc/


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

sqoop
cp sqoop/conf/sqoop-env-template.sh sqoop/conf/sqoop-env.sh
sqoop-env.sh
export HADOOP_COMMON_HOME=/opt/soft/hadoop
export HADOOP_MAPRED_HOME=/opt/soft/hadoop
export HIVE_HOME=/opt/soft/hive

上传 mysql-connector-java-5.1.24.jar 驱动至lib

用sqoop看mysql里的数据库
sqoop list-databases --connect jdbc:mysql://master:3306/ --username 
root --password 123456

用sqoop看mysql里的数据表
sqoop list-tables --connect jdbc:mysql://master:3306/hive --username 
root --password 123456

hbase
hbase-env.sh
启用自带的zookeeper
export HBASE_MANAGES_ZK=true
export JAVA_HOME=${JAVA_HOME}

hbase-site.xml
hbase.rootdir
/opt/soft/hbase/data

hbase.cluster.distributed
false

start-hbase.sh
hbase shell

status #查看数据库状态
version #查看Hbase版本
list #查看hbase数据库中的表

flume
cp flume/conf/flume-conf.properties.template ./flume-conf.properties

flume-conf.properties
# 定义agent里面的sources,channels,sinks
a1.sources = s1
a1.channels = c1
a1.sinks = k1
# 配置sources数据源
a1.sources.s1.type = spooldir
a1.sources.s1.spoolDir = /opt/soft/hadoop/logs
# 配置channels，做sources和channels绑定，指定channels用什么类型传输
a1.sources.s1.channels = c1
a1.channels.c1.type = memory
# 配置sinks，落地，存在hdfs
a1.sinks.k1.type = hdfs
a1.sinks.k1.hdfs.path = hdfs://master:9000/flume/%Y%m%dfs
a1.sinks.k1.hdfs.filePrefix = %Y%m%d-
a1.sinks.k1.hdfs.fileType = DataStream
a1.sinks.k1.channel = c1
a1.sinks.k1.hdfs.useLocalTimeStamp = true

hdfs dfs -mkdir /flume
flume-ng agent -n a1 -c conf -f $flume_conf/flume-conf.properties

spark
cp spark/conf/spark-env.sh.template ./spark-env.sh

echo 'export JAVA_HOME=${JAVA_HOME}'>>spark/conf/spark-env.sh
echo 'export SPARK_MASTER_HOST=localhost'spark/conf/spark-env.sh

cd /opt/soft/spark/sbin
./start-all.sh

kafka

echo "">>kafka/config/server.properties
echo "host.name=master">>kafka/config/server.properties (master)
echo "host.name=slave1">>kafka/config/server.properties (slave1)
echo "host.name=slave2">>kafka/config/server.properties (slave2)

echo "broker.id=0">>kafka/config/server.properties (master)
echo "broker.id=1">>kafka/config/server.properties (slave1)
echo "broker.id=2">>kafka/config/server.properties (slave2)

echo "log.dirs=/opt/soft/kafka/logs">>kafa/config/server.properties
echo "zookeeper.connect=master:2181,slave1:2181,slave2:2181">>kafa/config/server.properties

scp -r /opt/soft/kafka root@slave1:/opt/soft/
scp -r /opt/soft/kafka root@slave2:/opt/soft/

scp -r /etc/profile root@slave1:/etc/
scp -r /etc/profile root@slave2:/etc/

先启动hadoop和zookeeper
start-all.sh
zkServer.sh start
zkServer.sh status

kafka-server-start.sh -daemon /opt/soft/kafka/config/server.properties

kafka-topics.sh --create --zookeeper master:2181 --topic test
--replication-factor 1 --partitions 1
Create topic "test".

kafka-topics.sh --list --zookeepr master:2181
test

master执行，启动生产者
kafka-console-producer.sh --broker-list master:9092 --topic test

slave1执行，启动观察者
kafka-console-consumer.sh --bootstrap-server master:9092 --topic 
 test --from-beginning

 在master中输入:
 hello,world
 slave1中观察到：
 hello,world

 停止kafka
 kafka-server-stop.sh

