#!/bin/bash

#解压hive安装包
#echo -e "请输入hive的安装目录，如/usr/local/opt"
#read installpath

installpath=/usr/local/opt/install

#创建该目录,-d $installpath寻找该路径下是否有这个目录
if [ ! -d $installpath ];
then    
    mkdir -p $installpath
fi

#判断是否成功
if [ ! -d $installpath ];
then    
    echo "目录创建失败，请查看是否有权限"
    exit
fi

#解压安装包
currentdir=$(cd $(dirname $0);pwd)

ls|grep 'apache-hive-.*[gz]$'

if [ $? -ne 0 ];
then
    echo "在$currentdir没有发现hive的压缩包"
    exit
else
    tar -zxvf $currentdir/$(ls|grep 'apache-hive-.*[gz]$') -C $installpath
fi

#配置hive环境变量
insidepath=`ls $installpath|grep 'apache-hive-.*'`

#echo "">>/etc/profile
#echo '#hive'>>/etc/profile
#echo "export HIVE_HOME=$installpath/$insidepath">>/etc/profile
#echo 'export PATH=$PATH:$HIVE_HOME/bin'>>/etc/profile

#刷新环境变量
#source /etc/profile

#配置hive-site.xml与hive-default.xml
hivedir=$installpath/$insidepath #完整路径
confdir=$installpath/$insidepath/conf #完整配置文件路径

cp $confdir/hive-default.xml.template $confdir/hive-default.xml
cp $confdir/hive-default.xml.template $confdir/hive-site.xml


sed -i '/<configuration>/,/<\/configuration>/d' $confdir/hive-site.xml

echo "">>$confdir/hive-site.xml
echo '--><configuration>'>>$confdir/hive-site.xml
echo '</configuration>'>>$confdir/hive-site.xml

sed -i '/<\/configuration>/i\ <!--连接用户名-->' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <name>javax.jdo.option.ConnectionUserName</name>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <value>root</value>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ </property>' $confdir/hive-site.xml

sed -i '/<\/configuration>/i\ <!--连接密码-->' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <name>>javax.jdo.option.ConnectionPassword</name>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <value>123456</value>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ </property>' $confdir/hive-site.xml

sed -i '/<\/configuration>/i\ <!--连接URL-->' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <name>javax.jdo.option.ConnectionURL</name>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <value>jdbc:mysql://master:3306/hive</value>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ </property>' $confdir/hive-site.xml

sed -i '/<\/configuration>/i\ <!--连接驱动-->' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <property>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <name>javax.jdo.option.ConnectionDriverName</name>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ <value>com.mysql.jdbc.Driver</value>' $confdir/hive-site.xml
sed -i '/<\/configuration>/i\ </property>' $confdir/hive-site.xml

cp $currentdir/$(ls|grep 'mysql-.*[jar]$') $hivedir/lib

