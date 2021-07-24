#!/bin/bash

source zkServer.sh start
ssh slave1 "/usr/local/opt/install/zookeeper-3.4.5/bin/zkServer.sh start"
ssh slave2 "/usr/local/opt/install/zookeeper-3.4.5/bin/zkServer.sh start"
source start-all.sh
source start-hbase.sh
source /usr/local/opt/install/spark-2.3.2-bin-hadoop2.7/sbin/start-all.sh