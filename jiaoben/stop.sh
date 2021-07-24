#!/bin/bash

source /usr/local/opt/install/spark-2.3.2-bin-hadoop2.7/sbin/stop-all.sh
source stop-hbase.sh
source stop-all.sh
ssh slave1 "/usr/local/opt/install/zookeeper-3.4.5/bin/zkServer.sh stop"
ssh slave2 '/usr/local/opt/install/zookeeper-3.4.5/bin/zkServer.sh stop'
source zkServer.sh stop
