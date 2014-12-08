#!/bin/sh

# resolve links - $0 may be a softlink
this="${BASH_SOURCE-$0}"
common_bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
script="$(basename -- "$this")"
this="$common_bin/$script"

# convert relative path to absolute path
config_bin=`dirname "$this"`
script=`basename "$this"`
config_bin=`cd "$config_bin"; pwd`
this="$config_bin/$script"

NODES_FILE=$config_bin/../conf/nodes
NN_FILE=$config_bin/../conf/namenode
DN_FILE=$config_bin/../conf/datanode

NODES="`cat $NODES_FILE |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'`"

echo "[INFO]:Install hadoop rpms on namenode"
pssh -P -i -h $NN_FILE "yum install -y hadoop-debuginfo hadoop-doc hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode \
 		hadoop-mapreduce-historyserver hadoop-yarn-resourcemanager hive-metastore
"

echo "[INFO]:Install hadoop rpms on datanode"
pssh -P -i -h  $DN_FILE "yum install -y hadoop-debuginfo hadoop-doc hadoop-hdfs-datanode hadoop-yarn-nodemanager \
	hive-server2 hive-hbase zookeeper-server hbase-master hbase-regionserver
"

echo "Config hadoop alternatives ..."
pssh -P -i -H "$NODES" '
	rm -rf /data/dfs
	mkdir -p /data/dfs/{dn,nn,namesecondary} /data/yarn/{local,logs}
	chown -R hdfs:hdfs /data/dfs && chmod -R 700 /data/dfs/ && chown -R yarn:yarn /data/yarn

	#http://archive.cloudera.com/cdh4/cdh/4/hadoop/hadoop-project-dist/hadoop-hdfs/ShortCircuitLocalReads.html
	rm -rf /var/run/hadoop-hdfs/*	&& chown -R hdfs:hdfs /var/run/hadoop-hdfs/

	touch /var/lib/hive/.hivehistory && chown -R hive:hive /var/lib/hive/.hivehistory

	rm -rf /usr/lib/hive/lib/hive-hbase-handler.jar
	ln -s `ls /usr/lib/hive/lib/hive-hbase-handler*|head -n 1` /usr/lib/hive/lib/hive-hbase-handler.jar

	mkdir -p /usr/lib/hbase/lib/native/Linux-amd64-64/
	ln -sf /usr/lib64/libsnappy.so /usr/lib/hbase/lib/native/Linux-amd64-64/
'

myid=0
for server in $HOSTS ;do
	myid=`expr $myid + 1`
	echo -e "\n[INFO]:init zookeeper in $server ..."

	ssh -q root@$server  "
		service zookeeper-server stop
		pkill -9 zookeeper-server

		rm -rf /var/lib/zookeeper && mkdir /var/lib/zookeeper
		chown -R zookeeper:zookeeper /var/lib/zookeeper && chmod -R 700 /var/lib/zookeeper

		service zookeeper-server init --myid=$myid
	"
done
