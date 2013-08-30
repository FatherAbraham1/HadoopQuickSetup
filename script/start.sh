#!/bin/sh

if [ $# != 1 ]; then
	echo -e "USAGE:\n\t./start.sh start|stop|restart|status"; exit 1
fi

echo "[INFO]:Hadoop service hadoop $1"

NODES_FILE="/etc/edh/nodes.csv"
if [ -f $NODES_FILE ]; then
    	NODES_LIST="`cat $NODES_FILE`"
else
	echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi


for node in $NODES_LIST ;do
        ssh root@$node  "
	for x in hadoop-hdfs-namenode hadoop-hdfs-datanode hadoop-mapreduce-historyserver hadoop-yarn-resourcemanager hadoop-yarn-nodemanager zookeeper-server hbase-master hbase-regionserver hive-metastore hive-server2; do 
    			service \$x $1 ;
		 done
	"
done

