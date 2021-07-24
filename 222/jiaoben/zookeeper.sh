#!/bin/bash

#1.解压hadoop压缩包，设定hadoop安装路径
echo -e "请输入zookeeper的安装目录,例如/usr/local/opt/install"
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
ls | grep 'zookeeper-.*[gz]$'
if [ $? -ne 0 ]; then
  echo "在$currentdir没有发现zookeeper压缩包，上传到该路径下"
  exit
else
  tar -zxvf $currentdir/$(ls | ls | grep 'zookeeper-.*[gz]$') -C $installpath
fi

#配置zookeeper环境变量
#zookeeper路径
esbanben=`ls $installpath | grep 'zookeeper-.*'`

#配置/etc/profile 配置环境变量 zookeeper
echo "">>/etc/profile
echo '#zookeeper'>>/etc/profile
echo "export ZOOKEEPER_HOME=$installpath/$esbanben">>/etc/profile
echo 'export PATH=$PATH:$ZOOKEEPER_HOME/bin'>>/etc/profile
source /etc/profile

#配置
zookeeperdir=$installpath/$esbanben  #完整路径
confdir=$installpath/$esbanben/conf #完成配置文件路径

cp $confdir/zoo_sample.cfg $confdir/zoo.cfg

#配置zoo.cfg

old_dir='dataDir=/tmp/zookeeper'
new_dir='dataDir='$zookeeperdir/data
sed -i "s!${old_dir}!${new_dir}!g" $confdir/zoo.cfg
mkdir -p -m 777 $zookeeperdir/data

echo "">>$confdir/zoo.cfg
echo 'server.1=master:2888:3888'>>$confdir/zoo.cfg
echo 'server.2=slave1:2888:3888'>>$confdir/zoo.cfg
echo 'server.3=slave2:2888:3888'>>$confdir/zoo.cfg

echo '1'>>$zookeeperdir/data/myid

#分发
echo "请输入slave机的名称，用空格隔开"
read allnodes
array=(`echo  $allnodes | tr ' ' ' '`)
ii=2
  for allnode in ${array[@]}
    do
      echo ===$allnode====
      ssh $allnode "echo ''>>/etc/profile"
      ssh $allnode "echo '#zookeeper'>>/etc/profile"
      ssh $allnode "echo 'export ZOOKEEPER_HOME=$installpath/$esbanben'>>/etc/profile"
      ssh $allnode "echo 'export PATH=\$PATH:\$ZOOKEEPER_HOME/bin'>>/etc/profile"
      ssh $allnode "source /etc/profile"
      ssh $allnode "rm -rf $zookeeperdir"
      ssh $allnode "mkdir -p $zookeeperdir"
      scp -r $zookeeperdir/* root@$allnode:$zookeeperdir/
      ssh $allnode "chmod 777 $zookeeperdir/data"
      ssh $allnode "echo '$ii'>$zookeeperdir/data/myid"
      let ii=$ii+1
      echo ====$allnode完成====
    done

