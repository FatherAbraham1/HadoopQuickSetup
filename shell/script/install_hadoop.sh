#!/bin/sh

HOSTNAME=`hostname`
CONFIG_PATH=/etc/edh/conf
NODES_FILE=$CONFIG_PATH/nodes
MANAGER_FILE=$CONFIG_PATH/manager
TMP_FILE=/tmp/edh_tmp


echo "[INFO]:Install hadoop rpm on namenode"
pssh -P -i -h $MANAGER_FILE  "
	yum install -y hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode hadoop-mapreduce-historyserver hadoop-yarn-resourcemanager hive-metastore"

echo "[INFO]:Install hadoop rpm on datanode"
pssh -P -i -h  $NODES_FILE "
	yum install -y hadoop-hdfs-datanode hadoop-yarn-nodemanager hive-server2 hive-jdbc zookeeper-server hbase-master hbase-regionserver hbase-thrift
"

cat $MANAGER_FILE $NODES_FILE |uniq>$TMP_FILE

echo "Config hadoop alternatives ..."
pssh -P -i -h $TMP_FILE '
	rm -rf /etc/{hadoop,hive,hbase,zookeeper}/{conf,conf.my_cluster}
	mkdir -p /etc/{hadoop,hive,hbase,zookeeper}/conf.my_cluster

	for srv in hadoop hbase hive zookeeper ;do
		alternatives --install /etc/${srv}/conf ${srv}-conf /etc/${srv}/conf.my_cluster 50
		alternatives --set ${srv}-conf /etc/${srv}/conf.my_cluster
	done

	touch /var/lib/hive/.hivehistory
	chown -R hive:hive  /var/lib/hive/.hivehistory

	rm -rf /usr/lib/hive/lib/hive-hbase-handler.jar
	ln -s /usr/lib/hive/lib/hive-hbase-handler-0.10.0-cdh4.3.0.jar /usr/lib/hive/lib/hive-hbase-handler.jar
	
	mkdir -p /usr/lib/hbase/lib/native/Linux-amd64-64/
	ln -sf /usr/lib64/libsnappy.so /usr/lib/hbase/lib/native/Linux-amd64-64/
'
echo "Install hadoop rpm finish ..."



