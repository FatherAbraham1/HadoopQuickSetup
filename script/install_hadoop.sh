#!/bin/sh

HOSTNAME=`hostname`
CONFIG_PATH=/etc/edh
NODES_FILE=$CONFIG_PATH/nodes.csv
MANAGER_FILE=$CONFIG_PATH/manager.csv
TMP_FILE=/tmp/edh_tmp


echo "[INFO]:Install hadoop rpm on namenode"
mussh -m -u -b -t 6 -H $MANAGER_FILE -c "
	yum install -y hadoop hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode hadoop-mapreduce-historyserver hadoop-yarn hadoop-yarn-resourcemanager hive hive-metastore"

echo "[INFO]:Install hadoop rpm on datanode"
mussh -m -u -b -t 6 -H $NODES_FILE -c "
	yum install -y hadoop hadoop-debuginfo hadoop-hdfs-datanode hadoop-yarn hadoop-yarn-nodemanager hive hive-server2 hive-jdbc zookeeper zookeeper-server hbase hbase-master hbase-regionserver
"

cat $MANAGER_FILE $NODES_FILE |uniq>$TMP_FILE

echo "Config hadoop alternatives ..."
mussh -m -u -b -t 6 -H $TMP_FILE -c '
	rm -rf /etc/{hadoop,hive,hbase,zookeeper}/{conf,conf.edh}
	mkdir -p /etc/{hadoop,hive,hbase,zookeeper}/conf.edh

	for srv in hadoop hbase hive zookeeper ;do
		alternatives --install /etc/${srv}/conf ${srv}-conf /etc/${srv}/conf.edh 50
		alternatives --set ${srv}-conf /etc/${srv}/conf.edh
	done

	touch /var/lib/hive/.hivehistory
	chown -R hive:hive  /var/lib/hive/.hivehistory

	rm -rf /usr/lib/hive/lib/hive-hbase-handler.jar
	ln -s /usr/lib/hive/lib/hive-hbase-handler-0.10.0-cdh4.3.0.jar /usr/lib/hive/lib/hive-hbase-handler.jar
	
	ln -sf /usr/lib64/libsnappy.so /usr/lib/hbase/lib/native/Linux-amd64-64/
'
echo "Install hadoop rpm finish ..."



