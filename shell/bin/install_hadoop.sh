#!/bin/sh

readonly PROGNAME=$(basename $0)
readonly PROGDIR=$(readlink -m $(dirname $0))
readonly ARGS="$@"

NODES_FILE=$PROGDIR/../conf/nodes
NN_FILE=$PROGDIR/../conf/namenode
DN_FILE=$PROGDIR/../conf/datanode

NODES="`cat $NODES_FILE |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'`"

echo "[INFO]:Install hadoop on namenode"
pssh -P -i -h $NN_FILE "yum install -y hadoop-debuginfo hadoop-doc hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode \
 		hadoop-mapreduce-historyserver hadoop-yarn-resourcemanager hive-metastore
"

echo "[INFO]:Install hadoop on datanode"
pssh -i -h  $DN_FILE "yum install -y hadoop-debuginfo hadoop-doc hadoop-hdfs-datanode hadoop-yarn-nodemanager \
	hive-server2 hive-hbase zookeeper-server hbase-master hbase-regionserver
"
