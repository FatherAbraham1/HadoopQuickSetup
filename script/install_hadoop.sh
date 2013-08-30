#!/bin/sh

HOSTNAME=`hostname`
NODES_FILE="/etc/edh/nodes.csv"
MANAGER_FILE="/etc/edh/manager.csv"


echo "[INFO]:Install hadoop rpm on namenode"
mussh -m -u -b -t 6 -H $MANAGER_FILE -c "
		yum install -y -q hadoop hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode hadoop-mapreduce-historyserver hadoop-yarn hadoop-yarn-resourcemanager hive hive-metastore"

echo "[INFO]:Install hadoop rpm on datanode"
mussh -m -u -b -t 6 -H $NODES_FILE -c "
		yum install -y -q hadoop hadoop-debuginfo hadoop-hdfs-datanode hadoop-yarn hadoop-yarn-nodemanager hive hive-server2 hive-jdbc zookeeper zookeeper-server hbase hbase-master hbase-regionserver
"

TMP_FILE=/tmp/NODES
cat $MANAGER_FILE $NODES_FILE |uniq>$TMP_FILE

echo "Config hadoop alternatives ..."
mussh -m -u -b -t 6 -H $TMP_FILE -c "
		rm -rf /etc/{hadoop,hive,hbase,zookeeper}/{conf,conf.edh}
		mkdir -p /etc/{hadoop,hive,hbase,zookeeper}/conf.edh

		alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.edh 50
		alternatives --set hadoop-conf /etc/hadoop/conf.edh

		alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.edh 50
		alternatives --set hive-conf /etc/hive/conf.edh

		alternatives --install /etc/hbase/conf hbase-conf /etc/hbase/conf.edh 50
		alternatives --set hbase-conf /etc/hbase/conf.edh

		alternatives --install /etc/zookeeper/conf zookeeper-conf /etc/zookeeper/conf.edh 50
		alternatives --set zookeeper-conf /etc/zookeeper/conf.edh

		touch /var/lib/hive/.hivehistory
		chown -R hive:hive  /var/lib/hive/.hivehistory

		rm -rf /usr/lib/hive/lib/hive-hbase-handler.jar
		ln -s /usr/lib/hive/lib/hive-hbase-handler-0.10.0-cdh4.3.0.jar /usr/lib/hive/lib/hive-hbase-handler.jar
"

echo "Install hadoop rpm finish ..."



