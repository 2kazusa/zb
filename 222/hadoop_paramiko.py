import paramiko
from xml.etree import ElementTree

ssh_client = paramiko.SSHClient()
ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh_client.connect(hostname="192.168.28.175", port=22, username="root", password="???????")
sftp = ssh_client.open_sftp()

hadoop_remote_path = "/opt/soft/"
hadoop_local_file_path = "soft/hadoop-2.7.7.tar.gz"
hadoop_file_name = "hadoop-2.7.7.tar.gz"

# 上传压缩包至远程路径下
print("上传压缩包")
cmd_str = "ls -l %s" % hadoop_remote_path + hadoop_file_name
std_in, std_out, std_err = ssh_client.exec_command(cmd_str)
if std_out.channel.recv_exit_status() == 0:
    print("压缩包已存在")
else:
    sftp.put(hadoop_local_file_path, hadoop_remote_path + hadoop_file_name)
    print("上传完成")

hadoop_install_path = "/usr/project/"
hadoop_install_inpath = ""
print("解压文件")
cmd_str = "tar -zxvf %s -C %s" % (hadoop_remote_path + hadoop_file_name, hadoop_install_path)
std_in, std_out, std_err = ssh_client.exec_command(cmd_str)
res = std_out.readlines()
hadoop_install_inpath = res[0].split("/")[0]
print("解压后文件夹名称：" + hadoop_install_inpath)
print("解压完成")

print("修改环境变量")
cmd_str = "echo '#HADOOP环境变量'>>/etc/profile"
ssh_client.exec_command(cmd_str)
cmd_str = "echo 'export HADOOP_HOME=%s'>>/etc/profile" % (hadoop_install_path + hadoop_install_inpath)
ssh_client.exec_command(cmd_str)
cmd_str = "echo 'export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin'>>/etc/profile"
ssh_client.exec_command(cmd_str)
cmd_str = "bash --login -c 'source /etc/profile'"
ssh_client.exec_command(cmd_str)
print("环境变量配置完成")

# 创建hadoop相关目录
hadoop_dicts = ['/var/hadoop', '/var/hadoop/namenode', '/var/hadoop/disk1', '/var/hadoop/disk2', '/var/hadoop/tmp',
                '/var/hadoop/logs']
for dict in hadoop_dicts:
    # 查看相关目录是否存在，若存在则不创建
    cmd_str = "ls -l %s" % dict
    std_in, std_out, std_err = ssh_client.exec_command(cmd_str)
    if std_out.channel.recv_exit_status() == 0:
        print("%s目录已存在" % dict)
    else:
        cmd_str = "mkdir -p chmod777 %s" % dict
        std_in, std_out, std_err = ssh_client.exec_command(cmd_str)
        if std_out.channel.recv_exit_status() > 0:
            print("%s目录创建失败，请是否具有足够权限" % dict)
        else:
            print("%s目录创建完成" % dict)

# 配置hadoop
config_path = hadoop_install_path + hadoop_install_inpath + "/etc/hadoop/"
# 配置core-site.xml
# 下载core-site.xml至本地
# sftp.get(config_path + "core-site.xml", "soft/core-site.xml")
# core_site_xml = ElementTree.parse("soft/core-site.xml")
# root = core_site_xml.getroot()
# property = ElementTree.Element("property")
# name = ElementTree.Element("name")
# name.text = "hadoop.tmp.dir"
# value = ElementTree.Element("value")
# value.text = "/var/hadoop/tmp"
# property.append(name)
# property.append(value)
# root.append(property)
# core_site_xml.write("soft/core-site.xml", encoding="utf-8", xml_declaration=True, method='xml')
# sftp.put("soft/core-site.xml",config_path + "core-site.xml")
# print("完成配置core-site.xml")

# # 配置hdfs-site.xml
# # 下载hdfs-site.xml至本地
sftp.get(config_path + "hdfs-site.xml", "soft/hdfs-site.xml")
core_site_xml = ElementTree.parse("soft/hdfs-site.xml")
root = core_site_xml.getroot()
property = ElementTree.Element("property")
name = ElementTree.Element("name")
name.text = "dfs.namenode.name.dir"
value = ElementTree.Element("value")
value.text = "/var/hadoop/namenode"
property.append(name)
property.append(value)
root.append(property)
property = ElementTree.Element("property")
name = ElementTree.Element("name")
name.text = "dfs.datanode.data.dir"
value = ElementTree.Element("value")
value.text = "/var/hadoop/disk1,/var/hadoop/disk2"
property.append(name)
property.append(value)
root.append(property)
# property = ElementTree.Element("property")
# name = ElementTree.Element("name")
# name.text = "dfs.replication"
# value = ElementTree.Element("value")
# value.text = "1"
# property.append(name)
# property.append(value)
# root.append(property)
core_site_xml.write("soft/hdfs-site.xml", encoding="UTF-8", xml_declaration=True, method='xml')
sftp.put("soft/hdfs-site.xml",config_path + "hdfs-site.xml")
print("完成配置hdfs-site.xml")

# # 配置core-site.xml
# # 下载core-site.xml至本地
sftp.get(config_path + "core-site.xml", "soft/core-site.xml")
core_site_xml = ElementTree.parse("soft/core-site.xml")
root = core_site_xml.getroot()
property = ElementTree.Element("property")
name = ElementTree.Element("name")
name.text = "hadoop.tmp.dir"
value = ElementTree.Element("value")
value.text = "/var/hadoop/tmp"
property.append(name)
property.append(value)
root.append(property)

# 题目没有配置
property = ElementTree.Element("property")
name = ElementTree.Element("name")
name.text = "fs.defaultFS"
value = ElementTree.Element("value")
value.text = "hdfs://master:9000"
property.append(name)
property.append(value)
root.append(property)

core_site_xml.write("soft/core-site.xml", encoding="UTF-8", xml_declaration=True, method='xml')
sftp.put("soft/core-site.xml",config_path + "core-site.xml")
print("完成配置core-site.xml")

# # 配置yarn-site.xml
# # 下载yarn-site.xml至本地
sftp.get(config_path + "yarn-site.xml", "soft/yarn-site.xml")
core_site_xml = ElementTree.parse("soft/yarn-site.xml")
root = core_site_xml.getroot()
property = ElementTree.Element("property")
name = ElementTree.Element("name")
name.text = "yarn.resourcemanager.hostname"
value = ElementTree.Element("value")
value.text = "master"
property.append(name)
property.append(value)
root.append(property)
# property = ElementTree.Element("property")
# name = ElementTree.Element("name")
# name.text = "yarn.nodemanager.aux-services"
# value = ElementTree.Element("value")
# value.text = "mapreduce-shuffle"
# property.append(name)
# property.append(value)
# root.append(property)
core_site_xml.write("soft/yarn-site.xml", encoding="UTF-8", xml_declaration=True, method='xml')
sftp.put("soft/yarn-site.xml",config_path + "yarn-site.xml")
print("完成配置yarn-site.xml")

# # 配置mapred-site.xml
# # 下载mapred-site.xml.template至本地
sftp.get(config_path + "mapred-site.xml.template", "soft/mapred-site.xml")
core_site_xml = ElementTree.parse("soft/mapred-site.xml")
root = core_site_xml.getroot()
# property = ElementTree.Element("property")
# name = ElementTree.Element("name")
# name.text = "yarn.resourcemanager.hostname"
# value = ElementTree.Element("value")
# value.text = "master"
# property.append(name)
# property.append(value)
# root.append(property)
property = ElementTree.Element("property")
name = ElementTree.Element("name")
name.text = "mapreduce.framework.name"
value = ElementTree.Element("value")
value.text = "yarn"
property.append(name)
property.append(value)
root.append(property)
core_site_xml.write("soft/mapred-site.xml", encoding="UTF-8", xml_declaration=True, method='xml')
sftp.put("soft/mapred-site.xml",config_path + "mapred-site.xml")
print("完成配置mapred-site.xml")

# 配置slaves
print("配置slaves文件")
# cmd_str = "echo 'master'>>%s/slaves" % config_path
# ssh_client.exec_command(cmd_str)
cmd_str="echo 'master'>%s/slaves"%config_path
ssh_client.exec_command(cmd_str)
# cmd_str="echo 'slave2'>>%s/slaves"%config_path
# ssh_client.exec_command(cmd_str)
print("配置slaves文件完成")

print("创建master文件")
cmd_str = "echo ''>>%s/master" % config_path
ssh_client.exec_command(cmd_str)
print("创建master文件完成")

print("修改JDK路径至hadoop-env.sh")
cmd_str = "bash --login -c 'echo \"export JAVA_HOME=$JAVA_HOME\">>%s/hadoop-env.sh'" % config_path
ssh_client.exec_command(cmd_str)


print("拷贝hadoop文件到两个slave节点")



print("启动服务")
cmd_str = "bash --login -c 'start-all.sh'"
std_in, std_out, std_err = ssh_client.exec_command(cmd_str)
print("执行结果")
print(std_out.read().decode("utf8"))
print(std_err.read().decode("utf8"))


ssh_client.close()
