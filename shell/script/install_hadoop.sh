#!/bin/sh

HOSTNAME=`hostname`
CONFIG_PATH=/etc/edh/conf
NODES_FILE=$CONFIG_PATH/nodes
MANAGER_FILE=$CONFIG_PATH/manager
TMP_FILE=/tmp/edh_tmp


echo "[INFO]:Install hadoop rpm on namenode"
pssh -P -i -h $MANAGER_FILE  "
	yum install -y hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode hadoop-mapreduce-historyserver hadoop-yarn-resourcemanager hive-metastore
"

echo "[INFO]:Install hadoop rpm on datanode"
pssh -P -i -h  $NODES_FILE "
	yum install -y hadoop-hdfs-datanode hadoop-yarn-nodemanager hive-server2 hive-jdbc zookeeper-server hbase-master hbase-regionserver hbase-thrift
"

cat $MANAGER_FILE $NODES_FILE |uniq>$TMP_FILE

echo "Config hadoop alternatives ..."
pssh -P -i -h $TMP_FILE '
	rm -rf /data/dfs
	mkdir -p /data/dfs/{dn,nn,namesecondary} /data/yarn/{local,logs}
	chown -R hdfs:hdfs /data/dfs && chmod -R 700 /data/dfs/
	chown -R yarn:yarn /data/yarn

	#http://archive.cloudera.com/cdh4/cdh/4/hadoop/hadoop-project-dist/hadoop-hdfs/ShortCircuitLocalReads.html
	rm -rf /var/run/hadoop-hdfs/
	mkdir -p /var/run/hadoop-hdfs/
	chown -R hdfs:hdfs /var/run/hadoop-hdfs/

	touch /var/lib/hive/.hivehistory
	chown -R hive:hive  /var/lib/hive/.hivehistory

	rm -rf /usr/lib/hive/lib/hive-hbase-handler.jar
	ln -s `ls /usr/lib/hive/lib/hive-hbase-handler*|head -n 1` /usr/lib/hive/lib/hive-hbase-handler.jar
	
	mkdir -p /usr/lib/hbase/lib/native/Linux-amd64-64/
	ln -sf /usr/lib64/libsnappy.so /usr/lib/hbase/lib/native/Linux-amd64-64/
'

myid=0

for server in `cat $CONFIG_PATH/zookeepers` ;do
	myid=`expr $myid + 1`
	echo -e "\n[INFO]:init zookeeper in $server ..."

	ssh -q root@$server  "
		service zookeeper-server stop
		pkill -9 zookeeper-server

		rm -rf /var/lib/zookeeper/* ; mkdir /var/lib/zookeeper
		chown -R zookeeper:zookeeper /var/lib/zookeeper && chmod -R 700 /var/lib/zookeeper

		service zookeeper-server init --myid=$myid
	"
done

echo "Install hadoop finish ..."