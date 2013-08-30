#!/bin/sh

NODES_FILE="/etc/edh/nodes.csv"

for node in `cat $NODES_FILE` ;do
	echo "[INFO]:Syn hadoop conf files to $node"
	rsync /etc/hadoop/conf root@$node:/etc/hadoop -avz --delete
	rsync /etc/hive/conf root@$node:/etc/hive/conf -avz --delete
	rsync /etc/hbase/conf root@$node:/etc/hbase/conf -avz --delete
	rsync /etc/zookeeper/conf root@$node:/etc/zookeeper -avz --delete
done
