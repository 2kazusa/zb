#!/bin/bash

#1.解压hadoop压缩包，设定hadoop安装路径
echo -e "请输入kafka的安装目录,例如/usr/local/opt/install"
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
ls | grep 'kafka_.*[gz]$'
if [ $? -ne 0 ]; then
  echo "在$currentdir没有发现spark压缩包，上传到该路径下"
  exit
else
  tar -zxvf $currentdir/$(ls | ls | grep 'kafka_.*[gz]$') -C $installpath
fi

#配置zookeeper环境变量
#kafka路径
esbanben=`ls $installpath | grep 'kafka_.*'`

#配置/etc/profile 配置环境变量 hbase
echo "">>/etc/profile
echo '#kafka'>>/etc/profile
echo "export KAFKA_HOME=$installpath/$esbanben">>/etc/profile
echo 'export PATH=$PATH:$KAFKA_HOME/bin'>>/etc/profile
source /etc/profile

#配置
kafkadir=$installpath/$esbanben  #完整路径
confdir=$installpath/$esbanben/config #完成配置文件路径

echo "">>$confdir/server.properties
echo 'host.name=master'>>$confdir/server.properties

old_dir='log.dirs=/tmp/kafka-logs'
new_dir='log.dirs='$kafkadir/logs
sed -i "s!${old_dir}!${new_dir}!g" $confdir/server.properties
mkdir -p -m 777 $kafkadir/logs

old_dir2='zookeeper.connect=localhost:2181'
new_dir2='zookeeper.connect=master:2181,slave1:2181,slave2:2181'
sed -i "s!${old_dir2}!${new_dir2}!g" $confdir/server.properties

#分发s
echo "请输入slave机的名称，用空格隔开"
read allnodes
array=(`echo  $allnodes | tr ' ' ' '`)
ii=1
  for allnode in ${array[@]}
    do
      echo ===$allnode====
      ssh $allnode "echo ''>>/etc/profile"
      ssh $allnode "echo '#kafka'>>/etc/profile"
      ssh $allnode "echo 'export KAFKA_HOME=$installpath/$esbanben'>>/etc/profile"
      ssh $allnode "echo 'export PATH=\$PATH:\$KAFKA_HOME/bin'>>/etc/profile"
      ssh $allnode "source /etc/profile"
      ssh $allnode "rm -rf $kafkadir"
      ssh $allnode "mkdir -p $kafkadir"
      scp -r $kafkadir/* root@$allnode:$kafkadir/
      ssh $allnode "chmod 777 $kafkadir/logs"

      #ssh $allnode "old_dir=host.name=master"
      #ssh $allnode "new_dir=host.name=$allnode"
      ssh $allnode "sed -i 's!host.name=master!host.name=$allnode!g' $confdir/server.properties"

      #ssh $allnode "old_dir='broker.id=0'"
      #ssh $allnode "new_dir='broker.id='$ii"
      ssh $allnode "sed -i 's!broker.id=0!broker.id=$ii!g' $confdir/server.properties"

      let ii=$ii+1

      echo ====$allnode完成====
    done
