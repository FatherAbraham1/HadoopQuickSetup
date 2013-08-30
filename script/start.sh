#!/bin/sh

if [ $# != 1 ]; then
	echo -e "USAGE:\n\t./start.sh start|stop|restart|status"; exit 1
fi

NODES_FILE=/etc/edh/nodes.csv
MANAGER_FILE=/etc/edh/manager.csv

echo ""
for node in `cat $MANAGER_FILE` ;do
	echo "[INFO]:$1 namenode and secondarynamenode: $node"
        ssh root@$node  "
		for x in hadoop-hdfs-namenode hadoop-hdfs-secondarynamenode hadoop-mapreduce-historyserver hadoop-yarn-resourcemanager hive-metastore ; do 
    			service \$x $1 ;
		 done
	"
done

echo ""
for node in `cat $NODES_FILE` ;do
	echo "[INFO]:$1 datanode and zookeeper: $node"
        ssh root@$node  "
		for x in hadoop-hdfs-datanode hadoop-yarn-nodemanager zookeeper-server; do 
    			service \$x $1 ;
		 done
	"
done

echo ""
for node in `cat $NODES_FILE` ;do
	echo "[INFO]:$1 hbase-master and hive: $node"
        ssh root@$node  "
		for x in hbase-master hive-server2; do 
    			service \$x $1 ;
		 done
	"
done

for node in `cat $NODES_FILE` ;do
	echo "[INFO]:$1 hbase-regionserver: $node"
        ssh root@$node  "
		for x in hbase-regionserver; do 
    			service \$x $1 ;
		 done
	"
done
