#!/bin/bash
echo "请输入jdk存放的路径"
read jdk_path
echo "请输入jdk安装的路径"
echo install_path

#判断目录是否存在
if [ ! -d $install_path ]
then
 mkdir -p $install_path
fi

#判断创建是否成功
if [ ! -d $install_path ]
then
 echo '目录创建失败，请确认是否拥有权限'
 exit
fi

#解压jar包
cd $jdk_path
ls | grep 'jdk-.*[gz]$'
if [ $? -ne 0 ]
then
 echo "在$jdk_path下没有发现jdk压缩包，请上传"
 exit
else
 tar -zxvf $jdk_path/$(ls | ls | grep 'jdk-.*[gz]$') -C $install_path
fi

#获取解压文件名称
file_name=`ls $install_path | grep 'jdk.*'`

#配置环境变量
echo "" >> /etc/profile
echo "#配置jdk环境变量" >> /etc/profile
echo "export JAVA_HOME=$install_path/$file_name" >> /etc/profile
echo 'export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar' >> /etc/profile
echo 'export JRE_HOME=$JAVA_HOME/jre' >> /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile

#刷新环境变量
source /etc/profile

#验证
java -version
 